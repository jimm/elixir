#!/usr/bin/env ruby
#
# usage: schema_rb_to_phoenix.rb [-t] schema_file
#
# Outputs Phoenix model-generation commands from a Ruby on Rails schema.rb
# file.
#
# -t creates templates, too.
#
# PROBLEM: does not take into account order of relationships. Models that
# rely on other models may appear earlier, so if you try to run the output
# as-is it'll fail.

require 'active_support'

$generate_templates = false

class Table

  attr_accessor :name, :fields, :foreign_keys

  def initialize(name)
    @name = name
    @fields = []
    @foreign_keys = []
  end

  def integer(name, options={})
    if name =~ /(\w+)_id$/
      ref_name = ActiveSupport::Inflector.tableize($1)
      @foreign_keys << "#{$1}_id:references:#{ref_name}"
    else
      @fields << name
    end
  end

  %w(string datetime boolean float).each do |type|
    define_method(type) do |name, _opts=nil|
      @fields << "#{name}:#{type}" unless name =~ /^(created|updated)_at$/
    end
  end

  def method_missing(sym, *args)
    # nop
  end

  def to_s
    str = "mix phoenix.gen.#{$generate_templates ? 'html' : 'model'} #{ActiveSupport::Inflector.classify(@name)} #@name"
    @fields.each { |f| str << " #{f}" }
    @foreign_keys.each { |fk| str << " #{fk}" }
    str
  end
end


module ActiveRecord
  class Schema
    def self.define(options)
      yield
    end
  end
end

def create_table(name, options)
  table = Table.new(name)
  yield(table)
  puts table.to_s
end

def add_index(_table, _fields, _options={})
  # nop
end

def add_foreign_key(_table1, _table2, _options={})
  # nop
end

if __FILE__ == $PROGRAM_NAME

  if ARGV[0] == '-t'
    $generate_templates = true
    ARGV.shift
  end

  schema_file = ARGV[0]
  unless schema_file
    $stderr.puts "usage: schema_rb_to_phoenix.rb [-t] schema_file"
    exit 1
  end

  puts "mix ecto.create"
  require schema_file
end

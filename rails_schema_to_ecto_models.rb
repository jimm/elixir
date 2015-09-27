#!/usr/bin/env ruby
#
# usage: rails_schema_to_ecto_models [-o outdir] schema.rb

require 'fileutils'

$outdir = '.'

class String
  def singularize
    case self
    when /ies$/
      self.sub(/ies$/, 'y')
    when /([sx])es$/
      self.sub(/([sx])es$/, $1)
    when /s$/
      self.sub(/s$/, '')
    else
      self
    end
  end

  def class_case
    "#{self[0.1].upcase}#{self[1..-1].gsub(/_([a-z])/) {$1.upcase}}"
  end
end

module ActiveRecord
  class Schema
    def self.define(opts={})
      yield
    end
  end
end

class Table
  def initialize(name, f)
    @name, @f = name, f
    @f
  end
  def method_missing(sym, *args)
    opts = args[1] || {}
    field_opts = opts[:default] ? ", default: '#{opts[:default]}'" : ""
    @f.puts "    field :#{args[0]}, :#{sym}#{field_opts}"
  end
end

def create_table(name, opts={})
  File.open(File.join($outdir, "#{name.singularize}.ex"), 'w') do |f|
    f.puts <<EOS
class Candi.Model.#{name.singularize.class_case} do
  use Ecto.Model

  schema "#{name}" do
EOS
    t = Table.new(name, f)
    yield t
    f.puts <<EOS
  end
end
EOS
  end
end

def add_index(table, cols, opts={})
  puts "add_index on #{table}"
end

if __FILE__ == $PROGRAM_NAME
  if ARGV[0] == '-o'
    ARGV.shift
    $outdir = ARGV.shift
  end
  $outdir = File.join($outdir, "model")
  FileUtils.rm_rf($outdir)
  FileUtils.mkdir_p($outdir)
  load(ARGV[0])
end

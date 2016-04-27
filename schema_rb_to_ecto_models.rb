#!/usr/bin/env ruby
#
# usage: schema_rb_to_phoenix_models.rb schema_file module_name models_dir
#
# Outputs Phoenix model files from a Ruby on Rails schema.rb file.

require 'fileutils'
require 'active_support'
require 'active_support/core_ext/string/inflections'

$module_name = nil
$output_dir = nil


class Field
  attr_accessor :name, :type, :options
  def initialize(name, type, options)
    @name, @type, @options = name, type, options
  end
  def nullable?
    options[:null] != false
  end
  def not_nullable?
    options[:null] == false
  end
end


class Table

  @@tables = {}                 # k = table name, v = table

  attr_accessor :module_name, :name, :options, :fields, :foreign_keys,
                :has_many_associations

  def self.all_tables
    @@tables.values
  end

  def initialize(module_name, name, options={})
    @module_name, @name, @options = module_name, name, options
    @name = name
    @fields = []
    @foreign_keys = []
    @has_many_associations = []

    @@tables[name] = self
  end

  def integer(name, options={})
    if name =~ /(\w+)_id$/
      ref_name = ActiveSupport::Inflector.tableize($1)
      @foreign_keys << Field.new($1, full_module_name($1), options)
    else
      @fields << Field.new(name, ':integer', options)
    end
  end

  %w(string datetime date time uuid boolean float decimal).each do |type|
    define_method(type) do |name, options={}|
      db_type = case type.to_s
                when 'datetime'
                  'Ecto.DateTime'
                when 'date'
                  'Ecto.Date'
                when 'time'
                  'Ecto.Time'
                when 'uuid'
                  'Ecto.UUID'
                else
                  ":#{type}"
                end
      case name
      when 'created_at'
        if @updated_at
          @timestamps = true
        else
          @created_at = true
        end
      when 'updated_at'
        if @created_at
          @timestamps = true
        else
          @updated_at = true
        end
      else
        @fields << Field.new(name, db_type, options)
      end
    end
  end

  def method_missing(sym, *args)
    # nop
  end

  def create_has_many_references
    @foreign_keys.each do |fk|
      t = @@tables[fk.name.pluralize]
      if t
        t.has_many_associations << Field.new(@name, full_module_name, {})
      end
    end
  end

  def full_module_name(name=@name)
    "#{@module_name}.#{ActiveSupport::Inflector.classify(name)}"
  end

  def to_s
    required_fields = @fields.select(&:not_nullable?).map(&:name)
    optional_fields = @fields.select(&:nullable?).map(&:name)

    required_fields += @foreign_keys.select(&:not_nullable?).map{|fk| "#{fk.name}_id"}
    optional_fields += @foreign_keys.select(&:nullable?).map{|fk| "#{fk.name}_id"}

    belongs_to_suffix = options[:id] == false ? ', references: :id' : nil

    str = <<EOS
defmodule #{full_module_name} do
  use #{@module_name}.Web, :model

EOS

    if options[:id] == false
      str << "  @primary_key false\n"
    end

    str << <<EOS
  schema "#@name" do
EOS
    @fields.each do |field|
      str << "    field :#{field.name}, #{field.type}\n"
    end
    @foreign_keys.each do |fk|
      str << "    belongs_to :#{fk.name}, #{fk.type}#{belongs_to_suffix}\n"
    end
    @has_many_associations.each do |assoc|
      str << "    has_many :#{assoc.name}, #{assoc.type}\n"
    end
    if @timestamps
      str << "\n    timestamps inserted_at: :created_at\n"
    end
    str << <<EOS
  end

  @required_fields ~w(#{required_fields.join(' ')})
  @optional_fields ~w(#{optional_fields.join(' ')})

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\\\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
EOS
  end
end


module ActiveRecord
  class Schema
    def self.define(options)
      yield
    end
  end
end


class String
  include ActiveSupport::Inflector
end


def create_table(name, options)
  table = Table.new($module_name, name, options)
  yield(table)
end

def add_index(_table, _fields, _options={})
  # nop
end

def add_foreign_key(_table1, _table2, _options={})
  # nop
end

if __FILE__ == $PROGRAM_NAME

  schema_file, $module_name, $output_dir = *ARGV
  unless $output_dir
    $stderr.puts "usage: schema_rb_to_phoenix_models.rb schema_file module_name dir"
    exit 1
  end

  FileUtils.mkdir_p($output_dir)

  require schema_file

  Table.all_tables.each do |t|
    t.create_has_many_references
  end
  Table.all_tables.each do |t|
    File.open(File.join($output_dir, "#{t.name.singularize}.ex"), 'w') do |f|
      f.puts t.to_s
    end
  end
end

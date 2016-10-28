#!/usr/bin/env ruby
#
# For usage, run schema_rb_to_phoenix_models.rb -h
#
# Outputs Phoenix model files from a Ruby on Rails schema.rb file.

require 'fileutils'
require 'optparse'
require 'active_support'
require 'active_support/core_ext/string/inflections'

Options = Struct.new(:schema_file, :module_name, :output_dir, :use_name)
# Unfortunately, this has to be global because there's no way to pass
# it in to the methods create_table and friends.
$args = Options.new

module ActiveRecord
  class Schema
    def self.init(args)
      @@args = args
    end

    def self.define(_info, &block)
      new.instance_eval(&block)
    end

    def create_table(name, options)
      yield Table.new(@@args.module_name, @@args.use_name, name, options)
    end

    def add_index(*_args)
      # nop
    end

    def add_foreign_key(*_args)
      # nop
    end
  end
end

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

  def initialize(module_name, use_name, name, options={})
    @module_name, @use_name, @name, @options = module_name, use_name, name, options
    @use_name ||= "#{@module_name}.Web"
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
  use #{@use_name}, :model

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

  def changeset(model, params \\\\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
EOS
  end
end


class String
  include ActiveSupport::Inflector
end


def self.check_for_duplicate_names
  names = Table.all_tables.map(&:name).map(&:singularize)
  if names.length > names.uniq.length
    $stderr.puts "warning: there are duplicate names"
    $stderr.puts names.sort.join("\n")
    exit 1
  end
end

if __FILE__ == $PROGRAM_NAME

  op = OptionParser.new do |opts|
    opts.on('-sFILE', '--schema=FILE', 'Rails schema.rb file') do |f|
      $args.schema_file = f
    end
    opts.on('-mNAME', '--module=NAME', 'Model module prefix') do |name|
      $args.module_name = name
    end
    opts.on('-oDIR', '--output_dir=DIR', 'Model directory') do |dir|
      $args.output_dir = dir
    end
    opts.on('-uMOD', '--use=MOD', 'Module to use (default is NAME.Web)') do |mod|
      $args.use_name = mod
    end
    opts.on_tail('-h', '--help', 'Prints this help') do
      puts opts
      exit
    end
  end.parse!

  unless $args.module_name && $args.schema_file && $args.output_dir
    $stderr.puts "error: module name, schema file, and output dir are required"
    op.help                     # exits
  end

  FileUtils.mkdir_p($args.output_dir)

  ActiveRecord::Schema.init($args)
  require $args.schema_file

  Table.all_tables.each do |t|
    t.create_has_many_references
  end
  check_for_duplicate_names
  Table.all_tables.each do |t|
    File.open(File.join($args.output_dir, "#{t.name.singularize}.ex"), 'w') do |f|
      f.puts t.to_s
    end
  end
end

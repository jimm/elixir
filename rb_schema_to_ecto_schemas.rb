#!/usr/bin/env ruby
#
# For usage, run rb_schema_to_ecto_schemas.rb -h
#
# Outputs Ecto 2.0 schema files by reading a Ruby on Rails schema.rb file.
# Note that this script can know nothing about how you want to organize them
# into Phoenix contexts.

require 'fileutils'
require 'pathname'
require 'optparse'
require 'active_support'
require 'active_support/core_ext/string/inflections'

DEFAULT_USE_MODULE = "Ecto.Schema"
DEFAULT_MODULE_NAME = "Unnamed"

Options = Struct.new(
  :schema_file, :module_name, :output_dir, :use_name, :generate_changeset,
  :models, :print_schema
)
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
      yield Table.new(@@args.module_name, @@args.use_name, name, @@args.generate_changeset, options)
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

  def self.check_for_duplicate_names
    names = all_tables.map(&:name).map(&:singularize)
    if names.length > names.uniq.length
      $stderr.puts "warning: there are duplicate names"
      $stderr.puts names.sort.join("\n")
      exit 1
    end
  end

  def initialize(module_name, use_name, name, generate_changeset, options={})
    @module_name, @use_name, @name, @generate_changeset, @options =
      module_name, use_name, name, generate_changeset, options
    @use_name ||= DEFAULT_USE_MODULE
    @name = name
    @fields = []
    @foreign_keys = []
    @has_many_associations = []

    @@tables[name] = self
  end

  def integer(name, options={})
    if name =~ /(\w+)_id$/
      @foreign_keys << Field.new($1, full_module_name($1), options)
    else
      @fields << Field.new(name, ':integer', options)
    end
  end

  %w(string text datetime date time uuid boolean float decimal).each do |type|
    define_method(type) do |name, options={}|
      db_type = case type.to_s
                when 'text'
                  ':string'
                when 'datetime'
                  ':naive_datetime'
                when 'date'
                  ':date'
                when 'time'
                  ':naive_datetime'
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

  def model_name(name=@name)
    ActiveSupport::Inflector.classify(name)
  end

  def full_module_name(name=@name)
    if @module_name
      "#{@module_name}.#{model_name(name)}"
    else
      model_name(name)
    end
  end

  def schema(prefix = "")
    str = ''
    if options[:id] == false
      str << "#{prefix}@primary_key false\n"
    end

    str << "#{prefix}schema \"#@name\" do\n"
    @fields.each do |field|
      str << "#{prefix}  field :#{field.name}, #{field.type}\n"
    end
    @foreign_keys.each do |fk|
      str << "#{prefix}  belongs_to :#{fk.name}, #{fk.type}#{belongs_to_suffix}\n"
    end
    @has_many_associations.each do |assoc|
      str << "#{prefix}  has_many :#{assoc.name}, #{assoc.type}\n"
    end
    if @timestamps
      str << "\n#{prefix}  timestamps inserted_at: :created_at\n"
    end
    str << "#{prefix}end\n"
  end

  def to_s
    var_name = @name.singularize

    required_fields = @fields.select(&:not_nullable?).map(&:name)
    optional_fields = @fields.select(&:nullable?).map(&:name)

    required_fields += @foreign_keys.select(&:not_nullable?).map{|fk| "#{fk.name}_id"}
    optional_fields += @foreign_keys.select(&:nullable?).map{|fk| "#{fk.name}_id"}

    belongs_to_suffix = options[:id] == false ? ', references: :id' : nil

    str = <<~EOS
    defmodule #{full_module_name} do
      use #{@use_name}

    EOS

    str << schema("  ")

    if @generate_changeset
      str << <<EOS

  @required_fields ~w(#{required_fields.join(' ')})
  @optional_fields ~w(#{optional_fields.join(' ')})
  @all_fields @required_fields ++ @optional_fields

  def changeset(%#{@name.classify}{} = #{var_name}, attrs) do
    #{var_name}
    |> cast(attrs, @all_fields)
    |> validate_required(@required_fields)
  end
EOS
    end

    str << "end\n"
  end
end


class String
  include ActiveSupport::Inflector
end

def infer_module_name_from_dir(path)
  path = path.realpath
  while !path.root? && path.basename.to_s != 'lib'
    path = path.parent
  end
  if path.root? || path.basename.to_s != 'lib'
    $stderr.puts "warning: can not infer module name from path; using \"#{DEFAULT_MODULE_NAME}\""
    DEFAULT_MODULE_NAME
  else
    path.dirname.basename.to_s.classify
  end
end

if __FILE__ == $PROGRAM_NAME

  op = OptionParser.new do |opts|
    opts.on('-sFILE', '--schema=FILE', 'Rails schema.rb file') do |f|
      $args.schema_file = f
    end
    opts.on('-mNAME', '--module=NAME', 'Schema module prefix (default is app name inferred from output dir)') do |name|
      $args.module_name = name
    end
    opts.on('-oDIR', '--output-dir=DIR', 'Schema directory') do |dir|
      $args.output_dir = dir
    end
    opts.on('-uMOD', '--use=MOD', 'Module to `use` (default is Ecto.Schema)') do |mod|
      $args.use_name = mod
    end
    opts.on('-c', '--changeset', 'Generate `changeset` function (default is false)') do |_|
      $args.generate_changeset = true
    end
    opts.on('-d', '--model=MODEL', 'Comma-separated list of models to generate (default is all)') do |val|
      $args.models ||= []
      $args.models += val.split(',').map(&:strip)
    end
    opts.on('-p', '--print-schema', 'Output schema to stdout, do not generate file') do |_|
      $args.print_schema = true
    end
    opts.on_tail('-h', '--help', 'Prints this help') do
      puts opts
      exit
    end
  end
  op.parse!

  if $args.schema_file.nil?
    $stderr.puts "error: schema file is required"
    puts op
    exit 1
  end
  if $args.output_dir.nil? && !$args.print_schema
    $stderr.puts "error: output directory is required"
    puts op
    exit 1
  end

  if $args.output_dir
    p = Pathname.new($args.output_dir)
    p.mkpath
    $args.module_name ||= infer_module_name_from_dir(p)
  end

  ActiveRecord::Schema.init($args)
  require $args.schema_file

  Table.check_for_duplicate_names
  Table.all_tables.each do |t|
    t.create_has_many_references
  end

  tables = Table.all_tables
  if $args.models && $args.models.length > 0
    tables.select! { |t| $args.models.include?(t.model_name) }
  end
  tables.each_with_index do |t, i|
    if $args.print_schema
      puts() if i > 0
      puts t.schema
    else
      File.open(File.join($args.output_dir, "#{t.name.singularize}.ex"), 'w') do |f|
        f.puts t.to_s
      end
    end
  end
end

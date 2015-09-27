#!/usr/bin/env ruby
#
# usage: rails_models_to_ecto_models [-o outdir] app/models

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

if __FILE__ == $PROGRAM_NAME
  if ARGV[0] == '-o'
    ARGV.shift
    $outdir = ARGV.shift
  end

  FileUtils.rm_rf($outdir)
  FileUtils.mkdir_p($outdir)

  FileUtils.cp_r("#{ARGV[0]}", $outdir)

#   Dir["#{ARGV[0]}/**/*.rb"].each do |path|
#     translate(path)
#     path.sub(%r{.*app/models/}, '').sub(/.rb$/, /.ex/)
#     table_name = File.basename(path).sub(/.ex$/, '').pluralize

#     outfile = File.join($outdir, path)
#     FileUtils.mkdir_p(File.dirname(outfile))
#     File.open(outfile, 'w') do |f|
#       submodules = path.sub(/.rb$/, '').split('/').map(&:singularize).map(&:class_case).join(".")
#       f.puts <<EOS
# defmodule Candi.Model.#{submodules} do
#   use Ecto.Model

#   schema "#{name}" do
# EOS
#       # DO STUFF HERE
#       f.puts <<EOS
#   end
# end
# EOS
# end
# end
end

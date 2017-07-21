require 'parser/current'

require_relative 'sparrow/parser_config'
require_relative 'sparrow/cleaner'
require_relative 'sparrow/rewriter'

# for now run with ruby lib/sparrow.rb path/to/the/project/you/want/to/clean
Sparrow::Cleaner.new(Dir["#{ARGV.first}/**/*.rb"].to_a).process

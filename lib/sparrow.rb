require 'parser/current'

require 'sparrow/parser_config'
require 'sparrow/parser'
require 'sparrow/rewriter'

Sparrow::Parser.new(Dir["#{ARGV.first}/**/*.rb"].to_a).process

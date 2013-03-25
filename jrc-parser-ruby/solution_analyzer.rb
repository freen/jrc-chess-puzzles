#!/usr/bin/ruby
require 'json'
require_relative './jrcparser/solution_analyzer.rb'

# Get specified extraction configuration
json = File.read(ARGV[0])
json = JSON.parse(json)

# Run parser
parser = JrcParser::SolutionAnalyzer.new(json)
parser.run()
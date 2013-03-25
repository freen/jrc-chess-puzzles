#!/usr/bin/ruby
require 'json'
require_relative './jrcparser/main.rb'

# Get specified extraction configuration
json = File.read(ARGV[0])
extract_config = JSON.parse(json)

# Directory configuration:
this_directory = File.expand_path(File.dirname(__FILE__))

# Cache directory
cache_dir = this_directory + "/cache"

# Output directory
output_dir = this_directory + "/parsed_puzzles"

# Run parser
parser = JrcParser::Main.new(extract_config, cache_dir, output_dir)
parser.run()
#!/usr/bin/ruby
require 'json'
require_relative './jrcparser/main.rb'

# Get specified extraction configuration
json = File.read(ARGV[0])
extract_config = JSON.parse(json)

# Cache directory
cache_dir = File.expand_path(File.dirname(__FILE__))
cache_dir << "/cache"

# Run parser
parser = JrcParser::Main.new(extract_config, cache_dir)
parser.run()
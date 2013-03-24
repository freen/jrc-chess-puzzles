#!/usr/bin/ruby
require 'optparse'
require './lib/jrc-parser.rb'

options = {}

optparse = OptionParser.new do |opts|
  opts.banner = "Usage: parser.rb fetch [url]"

  opts.on( '-h', '--help', 'Display this screen' ) do
    puts opts
    exit
  end
end

optparse.parse!

case ARGV[0]
when "fetch"
  page_uri = ARGV[1]
  cache_dir = "/cache"
  cache_dir = File.expand_path(File.dirname(__FILE__)) + cache_dir
  parser = JrcParser.new(page_uri, cache_dir)
  puts parser.extract
else
  puts opt_parser
end
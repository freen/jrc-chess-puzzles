#!/usr/bin/ruby
require 'optparse'
require './lib/jrc-parser.rb'

options = {
    :player_to_move => 'w',
    :moves_until_checkmate => 1
}

optparse = OptionParser.new do |opts|
  opts.banner = "Usage: parser.rb [options] fetch [url]"

  opts.on('-p N', '--player N', String, "Which player is next to move for this puzzle set") do |player|
    options[:player_to_move] = player
  end

  opts.on('-m N', '--moves N', Float, "How many moves until checkmate for this puzzle set") do |moves|
    options[:moves_until_checkmate] = moves
  end

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
  parser = JrcParser.new(cache_dir)
  puzzles = parser.extract(page_uri, options[:player_to_move])
  puts puzzles
else
  puts opt_parser
end
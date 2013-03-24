require_relative './parser.rb'

module JrcParser
  class Main

    def initialize(extract_config, cache_dir)
      @parser = Parser.new(cache_dir)
      @config = extract_config
    end

    def run
      uri_prefix = @config['options']['page_address_prefix']
      sets = @config['sets']
      sets.map do |set|
          set['puzzles'] = []
          set['pages'].each do |page|
            uri = uri_prefix + page
            puzzles = @parser.extract(uri, set['player_to_move'])
            puzzles.map do |puzzle|
              puzzle[:page] = page
            end
            set['puzzles'] << puzzles
          end
          set['puzzles'].flatten!(1)
      end
      json_doc = JSON.generate(sets)
      puts json_doc
    end

  end
end
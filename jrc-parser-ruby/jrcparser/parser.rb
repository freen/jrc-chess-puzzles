require 'open-uri'
require 'nokogiri'
require 'sanitize'
require 'active_support'

module JrcParser
  class Parser

    def initialize(cache_dir)
      cache_options = { :expires_in => nil }
      @cache = ::ActiveSupport::Cache::FileStore.new(cache_dir, cache_options)
      @sanitizer_full = ::Sanitize.new
    end

    # Given page_uri, fetch and extract the puzzles
    # The board positions will feature {player_to_move} in their FEN notation
    def extract(page_uri, player_to_move)
      markup = get_page_markup(page_uri)
      @doc = ::Nokogiri::HTML(markup)
      get_puzzles(@doc, player_to_move)
    end

    private

      # Fetch page from filesystem cache, or download it from the URI
      def get_page_markup(page_uri)
        markup = @cache.read(page_uri)
        if markup.nil?
          # puts "Downloading page at address #{page_uri} ..."
          markup = open(page_uri).read
          @cache.write(page_uri, markup)
        else
          # puts "Found page in cache"
        end
        markup
      end

      # Given a JRC nokogiri document, fetch all the board positions
      def get_puzzles(doc, player_to_move)
        imgs = doc.xpath('//img').select do |img|
          img.attr('src').match(/[a-z]{2}_[dl]\.gif/)
        end
        boards = imgs.each_slice(64).to_a
        puzzles = []
        boards.map do |board|
          puzzle = ::Hash.new
          puzzle[:board] = board_to_fen(board, player_to_move)
          puzzle[:code] = fetch_puzzle_code(board)
          puzzle[:solution] = fetch_puzzle_solution(puzzle[:code], doc)
          puzzles << puzzle
        end
        puzzles
      end

      # Converts an array of 64 Nokogiri <img /> elements to Forsyth-Edwards Notation
      def board_to_fen(board, player_to_move)
        as_fen = ""
        ranks = board.each_slice(8).to_a
        ranks.each_with_index do |rank, index|
          as_fen << rank_to_fen(rank)
          as_fen << "/" if index < 7
        end
        as_fen << " " + player_to_move
      end

      # Convert a rank (array of nokogiri <img> node objects) to its FEN representation
      def rank_to_fen(rank)
        as_fen = ""
        blank_counter = 0;
        rank.each_with_index do |img, index|
          src = img.attr("src");

          # Blank square
          if src.match(/sq_[ld]\.gif/)
            blank_counter += 1
            as_fen << blank_counter.to_s if 7 == index

          # Square with a piece
          elsif src.match(/([wb])([rnbqkp])_[ld]\.gif/)
            if blank_counter > 0
              # Add blank spaces and reset blank counter
              as_fen << blank_counter.to_s
              blank_counter = 0
            end
            # Add the discovered space
            color = ::Regexp.last_match(1) # one of: wb
            piece = ::Regexp.last_match(2) # one of: rnbqkp
            case color
            when "w"
              as_fen << piece.upcase
            when "b"
              as_fen << piece
            end
          end

        end
        as_fen
      end

      # Fetch the puzzle's code from the document using the elements and
      # position of the board
      def fetch_puzzle_code(board)
        # Start with the first element of the board
        top_left_square = board[0]
        # Step backwards until we're at the title link of the puzzle
        node = top_left_square
        node = node.previous() until "a" == node.name() and node.attribute('name')
        puzzle_title_link = node
        puzzle_title_link.attribute('name').to_s
      end

      # Fetch the solution from the document using the puzzle's code string
      def fetch_puzzle_solution(code, doc)
        solution_title = doc.xpath('//a[contains(@name, "S' + code + '")]')
        # todo produce a warning if we can't identify the solution
        return "" unless 1 == solution_title.length
        node = solution_title[0].parent()
        node = node.next() until "ul" == node.name()
        text_without_markup = @sanitizer_full.clean(node.to_s)
        text_without_markup.strip
          .gsub("\n", ' ')
          .gsub(/\s{2,}/, ' ')
      end
  end
end
require 'uri'
require 'open-uri'
require 'nokogiri'
require 'active_support'

class JrcParser

  def initialize(page_uri, cache_dir)
    @page_uri = page_uri
    cache_options = { :expires_in => nil }
    @cache = ActiveSupport::Cache::FileStore.new(cache_dir, cache_options)
  end

  def extract
    markup = get_page_markup(@page_uri)
    @doc = Nokogiri::HTML(markup)
    puzzles = get_puzzles(@doc)
    puts puzzles
  end

  private

    # Fetch page from filesystem cache, or download it from the URI
    def get_page_markup(page_uri)
      markup = @cache.read(page_uri)
      if markup.nil?
        puts "Downloading page at address #{page_uri} ..."
        markup = open(page_uri).read
        @cache.write(page_uri, markup)
      else
        puts "Found page in cache"
      end
      markup
    end

    def get_puzzles(doc)
      imgs = doc.xpath('//img').select do |img|
        img.attr('src').match(/[a-z]{2}_[dl]\.gif/)
      end
      boards = imgs.each_slice(64).to_a
      boards.map do |board|
        board = board_to_fen(board)
      end
    end

    # Converts an array of 64 Nokogiri <img /> elements to Forsyth-Edwards Notation
    def board_to_fen(board)
      as_fen = ""
      ranks = board.each_slice(8).to_a
      ranks.each_with_index do |rank, index|
        as_fen << rank_to_fen(rank)
        as_fen << "/" if index < 7
      end
      as_fen
    end

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
          color = Regexp.last_match(1) # one of: wb
          piece = Regexp.last_match(2) # one of: rnbqkp
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
end
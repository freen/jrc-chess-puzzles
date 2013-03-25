require 'pp'

module JrcParser
  class SolutionAnalyzer

    def initialize(puzzle_set)
      @puzzle_set = puzzle_set
    end

    def run
      move = "[QNRBKPqnrbkp](x?[a-h][1-8]|=[KQkq])"
      mate = "((is\\s)?mate\\s?(\\.|!{1,3})?)"
      solution = "/(\\d\\.\\s?#{move} (#{mate})? (or #{move})? #{mate}?){1,}/"
      # mate = "(is\\s)?mate\\s?(\\.|!{1,3})?"
      # move = "(\\d\\.\\s?#{move}(\\s#{mate})?)"
      # solution = "/#{move}"

      puts "Solution pattern: #{solution}"

      results = {
        :matches => {},
        :mismatches => []
      }

      @puzzle_set['puzzles'].each do |puzzle|
        if puzzle['solution'].match(solution)
          results[:matches] << {
            :solution => puzzle['solution'],
            :match => ::Regexp.last_match.to_a
          }
        else
          results[:mismatches] << puzzle['solution']
        end
      end

      pp results

    end

  end
end
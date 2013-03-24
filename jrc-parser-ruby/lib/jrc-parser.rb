require 'uri'
require 'open-uri'
require 'nokogiri'
require 'itrigga-file_cache'

class JrcParser

  def initialize(page_uri)
    @page_uri = page_uri
  end

  def extract
      puts "Downloading page at address #{@page_uri} ..."
      @doc = Nokogiri::HTML( open( @page_uri ) )
  end
end
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
end
require 'open-uri'

module ItemsHelper
  def format_price price
    number_with_delimiter(price.to_i)
  end

  # url for Rakuten in-shop item search
  def to_rakuten_esearch_url(sitem)
    "http://esearch.rakuten.co.jp/rms/sd/esearch/vc?sitem=#{u(sitem)}&sid=#{#}&sv=6&v=3&f=A"
  end
  
  # the result of the number of page of Rakuten in-shop item search
  def result_num_in_esearch(url)
    (open(url).read =~ /全\s*(.*?)\s*件/) ? Regexp.last_match(1).to_i : 0
  end
end

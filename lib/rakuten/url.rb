require 'hpricot'
require 'open-uri'
require 'enumerator'	# for each_slice
require 'nkf'

# FIXME: rename me RMS or NRMS (NewRMS)
# FIXME: rename me as Util
module Rakuten::Url

  # 一行に表示する件数
  @@SIZE_IN_ROW = 4
  #
  @@SIZE_OF_THUMBNAIL = 80


  class << self
    def raw_string_to_items(str, boundary = /[\r\n]+/)
      str.split(boundary).compact.map { |url| item_info(url) }
    end

    def item_info(options)
      url = case options
            when String
              options
            else # FIXME: implement for Hash!
              options.to_s
            end
      url.strip!

      # 不正な文字列・から文字列
      return {:url => url} if url.blank? or url !~ %r(^http|https://)
      # 
      return item if item = Item.find_by_url(url)

      doc = Hpricot(open(url))
      res = {
        :name => NKF.nkf("-m0 -Ew", (doc/".item_name/b").inner_html),
        :price => NKF.nkf("-m0 -Ew", (doc/"span.price2").inner_html.to_s.gsub(/[^\d\.]+/, "")),
        :image => NKF.nkf("-m0 -Ew", ((doc/"div/table/tr/td/table[2]/tr/td/table/tr[2]/td[3]/table[2]/tr/td/table[3]/tr/td/a/img") || {}).first[:src].sub(/(_ex=)\d+x\d+/, '\\1' + Array.new(2, @@SIZE_OF_THUMBNAIL) * "x")),
        :description => NKF.nkf("-m0 -Ew", ((doc/"div/table/tr/td/table[2]/tr/td/table/tr[2]/td[3]/table[2]/tr/td/table[3]/tr/td/a/img") || {}).first[:src].sub(/(_ex=)\d+x\d+/, '\\1' + Array.new(2, @@SIZE_OF_THUMBNAIL) * "x")),
      }
      item = Item.new(res)
      item.save!
      item
    end
  end

end

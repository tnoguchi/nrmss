require 'hpricot'
require 'open-uri'
require 'enumerator'	# for each_slice
require 'nkf'

# FIXME: rename me RMS or NRMS (NewRMS)
# FIXME: rename me as Util
module Rakuten::Url

  # 一行に表示する件数
  @@SIZE_IN_ROW = 4
  # サムネイル画像の横幅 (単位: px)
  @@SIZE_OF_THUMBNAIL = 80


  class << self
    def raw_string_to_items(str, boundary = /[\r\n]+/)
      str.split(boundary).compact.map { |url| item_info(url) }
    end

    def resize_thumbnail_url(url, size = @@SIZE_OF_THUMBNAIL)
      url.to_s.sub(/(_ex=)\d+x\d+/, '\\1' + Array.new(2, size) * "x")
    end

    # URL文字列からitem生成、そして、情報更新
    def item_info(options)
      url = case options
            when String
              options
            else # FIXME: implement for Hash!
              options.to_s
            end
      url.strip!

      # 不正な文字列・空文字列
      return {:url => url} if url.blank? or url !~ %r(^http|https://)

      item = Item.find_by_url(url) || Item.new(:url => url)

      item.update_info_from_rakuten
    end

    # TODO: DEPRECATED
    def update_item_info(item)
      logger.warn("Rakuten::Url.update_item_info was deprecated!")
      item.update_info_from_rakuten
    end

    # Hpricot を使ったパーサ
    # TODO: Rakuten::Parseに移動
    def parse_html_to_hash(url)
      doc = Hpricot(NKF.nkf("-m0 -Ew", open(url).read))
      result = {
        :name => (doc/".item_name/b").inner_html.to_s.gsub(/<br.*?>/, " "),
        :price => (doc/"span.price2").inner_html.to_s.gsub(/[^\d\.]+/, ""),
        :image => resize_thumbnail_url(((doc/"div/table/tr/td/table[2]/tr/td/table/tr[2]/td[3]/table[2]/tr/td/table[3]/tr/td/a/img").first || {})[:src]),
        :description => resize_thumbnail_url(((doc/"div/table/tr/td/table[2]/tr/td/table/tr[2]/td[3]/table[2]/tr/td/table[3]/tr/td/a/img").first || {})[:src]),
        :amount => (doc.search ".soldout_msg").any? ? 0 : (doc/".rest").inner_html.to_s.gsub(/[^\d\.]+/, "").to_i,
        :category_names => (doc/".sdtext a").map { |e| e.inner_html }.uniq.delete("カテゴリトップ")
      }
      # FIXME: tentative process
      result[:description] += result[:category_names]
      result
    end

  end

end

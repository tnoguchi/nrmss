require 'nkf'
require 'jcode'	# for String#tr

class IframeGenerator
  include ERB::Util	# h, u
  include ActionView::Helpers::NumberHelper	# number_with_delimiter
  include ActionView::Helpers::TagHelper	# content_tag
  include ActionView::Helpers::AssetTagHelper	# image_tag
  include ActionView::Helpers::UrlHelper	# link_to

  @@base_path = File.join(RAILS_ROOT, "/tmp/related_items/")
  cattr_reader :base_path

  def initialize erb_file = RAILS_ROOT + "/app/views/lib/rms/_default.html.erb"
    if File.exist? erb_file
      @_e = ERB.new open(erb_file).read, nil, '-' 
    else
      raise NotFoundFile, erb_file
    end
  end
  
  def render item, items
=begin
# cannot bind variables... X(
    item, items = nil, nil
    locals.each do |key, value|
      self.instance_eval "key = value"
    end
=end
    @_e.result(binding)
  end

  class << self
    def generate_all
      # ディレクトリ
      FileUtils.mkdir_p(self.base_path)

      # ジェネレータ
      ig = IframeGenerator.new
      items = Item.find(:all)
      puts "#{items.size} items to update are found!"
      items.each do |item|
        item_identifier = item.url.sub(/\A.*?rakuten\...\.jp\/?/, '').sub(/\/\Z/, '').gsub('/', '_')
        item.groups.each do |group|
          suffix = (!group.is_a? Array || group.size == 1) ? '' : "_#{group.id}"
          regulated_name = NKF.nkf('-We -m0', item.name.gsub(/[ 　]+/, ' ').tr("［］０-９ａ-ｚＡ-Ｚ", "[]0-9a-zA-Z"))
          open(File.join(self.base_path, "#{item_identifier}#{suffix}.html"), "w") do |f|
            f.puts <<-EOS
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="ja-JP" xmlns="http://www.w3.org/1999/xhtml" xml:lang="ja">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=EUC-JP" />
<meta http-equiv="Content-Style-Type" content="text/css">
<meta name="keywords" content="#{Nrmss.config['iframe_keywords']},#{regulated_name.gsub(/ +/,",")}" />
<title>#{regulated_name}#{NKF.nkf('-We -m0', 'の関連商品')}</title>
<link href="#{item.url.sub(%r{//item.rakuten.co.jp/([^/]+)/([^/])+/}, "//www.rakuten.ne.jp/gold/\\1/")}css/related_items.css" media="screen" rel="stylesheet" type="text/css" />
</head><body>
            EOS
            f.puts NKF.nkf('-We -m0', ig.render(item, group.items))
            f.puts <<-EOS
</body></html>
            EOS
          end
        end
      end
      open(File.join(self.base_path, "index.html"), "w") do |f|
        f.puts <<-EOS
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="ja-JP" xmlns="http://www.w3.org/1999/xhtml" xml:lang="ja">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=EUC-JP" />
<meta http-equiv="Content-Style-Type" content="text/css">
<meta name="keywords" content="#{Nrmss.config['iframe_keywords']}" />
<title>#{NKF.nkf('-We -m0', '関連商品リスト')}</title>
<link href="#{items.first.url.sub(%r{//item.rakuten.co.jp/([^/]+)/([^/])+/}, "//www.rakuten.ne.jp/gold/\\1/")}css/related_items.css" media="screen" rel="stylesheet" type="text/css" />
</head>
<body>
<h1>#{NKF.nkf('-We -m0', '関連商品リスト')}</h1>
<ul>
        EOS
        items.each do |item|
          regulated_name = NKF.nkf('-We -m0', item.name.gsub(/[ 　]+/, ' ').tr("［］０-９ａ-ｚＡ-Ｚ", "[]0-9a-zA-Z") + 'の関連商品')
          item_identifier = item.url.sub(/\A.*?rakuten\...\.jp\/?/, '').sub(/\/\Z/, '').gsub('/', '_')
          f.puts %Q|<li><a href="#{item_identifier}.html">#{regulated_name}</a></li>|
        end
        f.puts <<-EOS
</ul>
</body>
</html>
        EOS
      end
    end
 
    def backup_base_dir
      base_dir = IframeGenerator.base_path
      if File.exist?(base_dir)
        target_dir = base_dir.sub(/#{File::SEPARATOR}\Z/, '') + File.mtime(base_dir).strftime('_%Y%m%d_%H%M%S')
        puts "#{base_dir.sub(/\A#{RAILS_ROOT}/, '')} -> #{target_dir.sub(/\A#{RAILS_ROOT}/, '')}"
        FileUtils.cp_r(base_dir, target_dir)
        puts "html file backup was made."
      else
        puts "#{base_dir.sub(/\A#{RAILS_ROOT}/, '')} is not found. No need to backup yet."
      end

    end
  end
end

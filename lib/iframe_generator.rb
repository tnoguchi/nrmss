#require 'erb'
require 'nkf'

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
          open(File.join(self.base_path, "#{item_identifier}#{suffix}.html"), "w") do |f|
            f.puts <<-EOS
<html><head><meta http-equiv="Content-Type" content="text/html; charset=EUC-JP">

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

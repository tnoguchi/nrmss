namespace :item do
  desc "Item-related tasks"
  task :fetch => :environment do
    desc "Fetch pages from Rakuten and update item info"
    puts "It may take long time."
    require File.join(RAILS_ROOT, 'config/boot.rb')
    (items =Item.find(:all)).each { |item| item.update_info_from_rakuten }
    puts "#{items.size} items have been updated."
  end
  namespace :html do
    desc "html update"
    task :update => :environment do
      desc "Update html files for iframe (related items)"
      require File.join(RAILS_ROOT, 'config/boot.rb')
      require 'iframe_generator'
      IframeGenerator.generate_all
    end
  end
end

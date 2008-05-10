class ItemsController < ApplicationController
  # GET /items
  # GET /items.xml
  def index
    cond, inc_tables = for_group_id
    unless params[:q].blank?
      cond = [ 'name LIKE ?', "%#{params[:q].strip}%" ]
      inc_tables = nil
    end
 
    @items = Item.find(:all, :include => inc_tables, :conditions => cond)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @items }
    end
  end

  # GET /items/1
  # GET /items/1.xml
  def show
    @item = Item.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @item }
    end
  end

  # GET /items/new
  # GET /items/new.xml
  def new
    @item = Item.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @item }
    end
  end

  # GET /items/1/edit
  def edit
    @item = Item.find(params[:id])
  end

  # POST /items
  # POST /items.xml
  def create
    @item = Item.new(params[:item])

    respond_to do |format|
      if @item.save
        flash[:notice] = 'Item was successfully created.'
        format.html { redirect_to(@item) }
        format.xml  { render :xml => @item, :status => :created, :location => @item }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /items/1
  # PUT /items/1.xml
  def update
    @item = Item.find(params[:id])

    respond_to do |format|
      if @item.update_attributes(params[:item])
        flash[:notice] = 'Item was successfully updated.'
        format.html { redirect_to(@item) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /items/1
  # DELETE /items/1.xml
  def destroy
    @item = Item.find(params[:id])
    @item.destroy

    respond_to do |format|
      format.html { redirect_to(items_url) }
      format.xml  { head :ok }
    end
  end

  # /items/search_from_rakuten
  def search_from_rakuten
    require 'hpricot'
    require 'open-uri'

    @items = []
    unless params[:url].blank?
      url_list = params[:url].to_a
      # ページ処理
      if url_list.first =~ %r{^http://item.rakuten.co.jp/grandvin/c/[\d]+/$}
        (2..10).each do |i|
          url_list << params[:url] + "?p=#{i}"
        end
      end

      url_list.each do |url|
        doc = Hpricot(NKF.nkf("-m0 -Ew", open(url).read))
        @items += doc.search("a").select do |e|
          e.attributes["href"] =~ %r{^http://item.rakuten.co.jp/[^/]*/[^/]{2,}/$} &&
            ! e.inner_html.include?('thumbnail.image.rakuten.co.jp')
        end
      end
    end
    # アンカー名でソート
    @items.sort! { |a, b| a.inner_html <=> b.inner_html }

    @group_candidates = @items.partitions { |i| i.inner_html.gsub(/[ 　].*$/, '') }
    # アンカー名でソート
    @group_candidates.sort! { |a, b| a.first.inner_html <=> b.first.inner_html }
  end

  def update_rakuten_item_info
    @item = Item.find(params[:id])

    Rakuten::Url.item_info(@item.url)
  end

  private
  def for_group_id
    cond, inc_tables = nil, nil
    unless params[:group_id].blank?
      cond = [ "assigns.group_id = ?", params[:group_id] ]
      inc_tables = [ :assigns ]
    end
    [ cond, inc_tables ]
  end
end

class GroupsController < ApplicationController
  # GET /groups
  # GET /groups.xml
  def index
    @groups = Group.find(:all, :order => 'preference ASC')

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @groups }
    end
  end

  # GET /groups/1
  # GET /groups/1.xml
  def show
    @group = Group.find(params[:id], :include => [ :items ] ) #:items

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @group }
    end
  end

  # GET /groups/new
  # GET /groups/new.xml
  def new
    @group = Group.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @group }
    end
  end

  # GET /groups/1/edit
  def edit
    @group = Group.find(params[:id])
  end

  # POST /groups
  # POST /groups.xml
  def create
    @group = Group.new(params[:group])

    @successful = true
    flash[:notice] = ""
    @successful &&= @group.save
    # save items specified in 'urls' parameters
    @successful &&= urls_to_items_and_assigns(params[:urls].to_s)

    respond_to do |format|
      if @successful
        flash[:notice] += 'Group was successfully created.'
        format.html { redirect_to(@group) }
        format.xml  { render :xml => @group, :status => :created, :location => @group }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @group.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /groups/1
  # PUT /groups/1.xml
  def update
    @group = Group.find(params[:id])

    @successful = true
    flash[:notice] = ""
    @successful &&= @group.update_attributes(params[:group])
    @group.items.each { |item| item.update_info_from_rakuten }
    # save items specified in 'urls' parameters
    @successful &&= urls_to_items_and_assigns(params[:urls].to_s)

    params[:items_delete].to_a.map do |item_id|
      if assign = Assign.find(:first, :conditions => [ 'group_id = ? AND item_id = ?', @group.id, item_id.to_i ])
        assign.destroy && (flash[:notice] += "'#{assign.item.name}' was deleted.<br>\n")
      end
    end

    respond_to do |format|
      if @successful
        flash[:notice] += 'Group was successfully updated.'
        format.html { redirect_to(@group) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @group.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /groups/1
  # DELETE /groups/1.xml
  def destroy
    @group = Group.find(params[:id])
    @group.destroy

    respond_to do |format|
      format.html { redirect_to(groups_url) }
      format.xml  { head :ok }
    end
  end

  private
  # 改行で区切られたURLを含む文字列からItemインスタンスの配列を生成などする
  def urls_to_items_and_assigns(str)
    begin
      items = Rakuten::Url.raw_string_to_items(str).compact
    rescue
      flash[:notice] += "error"
    end

    items.each do |item|
      Assign.new(:group_id => @group.id, :item_id => item.id).save! if item.is_a?(Item)
    end
    @successful
  end

end

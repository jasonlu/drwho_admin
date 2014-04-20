class PagesController < ApplicationController
  before_action :set_page, only: [:show, :edit, :update, :destroy]

  # GET /admin/pages
  def index
    @pages = Page.all
  end

  # GET /admin/pages/1
  def show
  end

  # GET /admin/pages/new
  def new
    @page = Page.new
  end

  # GET /admin/pages/1/edit
  def edit
  end

  # POST /admin/pages
  def create
    @page = Page.new(page_params)

    if @page.save      
      redirect_to pages_path, notice: 'Page was successfully updated.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /admin/pages/1
  def update
    if @page.update!(page_params)
      redirect_to pages_path, notice: 'Page was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /admin/pages/1
  def destroy
    @page.destroy
    redirect_to pages_path, notice: 'Page was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_page
      @page = Page.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def page_params
      params[:page]
    end
end

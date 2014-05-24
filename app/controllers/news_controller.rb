class NewsController < ApplicationController
  before_action :set_news, only: [:show, :edit, :update, :destroy]

  def index
    sort = params[:sort]
    dir = params[:dir]
    @news = News.all.order(sort + ' ' + dir).page(params[:page])
  end

  def show
  end
  
  def new
    @news = News.new
  end

  def edit
  end

  def create
    @news = News.new(news_params)

    if @news.save
      redirect_to news_index_path, notice: 'News was successfully updated.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /admin/news/1
  def update
    if @news.update!(news_params)
      redirect_to news_index_path, notice: 'News was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /admin/news/1
  def destroy
    @news.destroy
    redirect_to news_index_path, notice: 'News was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_news
      @news = News.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def news_params
      params[:news][:user_id] = current_admin.id
      params.require(:news).permit(:id, :content, :title, :user_id, :publish_at, :close_at)
    end
end

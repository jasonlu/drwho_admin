class CategoriesController < ApplicationController
  before_action :set_category, only: [:show, :edit, :update, :destroy, :hide, :unhide]

  # GET /admin/courses
  def index
    sort = params[:sort]
    dir = params[:dir]

    case sort
    when 'category'
      sort = 'categories.title'
    when 'title', 'serial', 'price', 'unit'
    else
      sort = 'id'
    end

    @categories = Category.all.order(sort + ' ' + dir).page(params[:page])
  end

  def show
  end

  def new
    @category = Category.new
  end

  def edit
  end

  def create
    @category = Category.new(category_params)
    if @category.save
      redirect_to @category, notice: t('create_category_successful')
    else
      render action: 'new', notice: @category.errors
    end
    
  end

  def update
    if @category.update(category_params)
      redirect_to categories_url, notice: 'Category was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def destroy
    old_id = @category.id
    @courses = @category.courses.all
    total_categories = Category.all.length
    if total_categories <= 1
      redirect_to categories_url, notice: 'You cannot delete the last category.'
    else
      @category.destroy
      if @courses.length > 0
        Course.where(:category_id => old_id).update_all(:category_id => Category.first.id)
      end
      redirect_to categories_url, notice: 'Category was successfully destroyed.'
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_category
      @category = Category.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def category_params
      params.require(:category).permit(:id, :title)
    end
end

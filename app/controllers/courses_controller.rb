class CoursesController < ApplicationController
  before_action :set_course, only: [:show, :edit, :update, :destroy, :hide, :unhide]

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

    
    
    @courses = Course.all.joins(:category).order(sort + ' ' + dir).page(params[:page])
  end

  # GET /admin/courses/1
  def show
  end

  def hide
    @course.start_at = "2000-01-01 00:00:00"
    @course.end_at = @course.start_at
    @course.save
    redirect_to courses_url, notice: 'Course was successfully hide.'
  end

  def unhide
  end

  # GET /admin/courses/new
  def new
    @course = Course.new
    @course.duration_days = 28
    @course.start_at = Date.today
    @course.end_at = Date.today + 365
    @course.due_at = @course.end_at
    @course.price = 1500
    #@course.serial = Course.generate_serial
  end

  # GET /admin/courses/1/edit
  def edit
  end

  # POST /admin/courses
  def create
    #params[:serial] = Time.now.to_i

    @course = Course.new(course_params)


    if @course.save
      id = @course.id

      uploaded_io = params[:course][:course_items_file]
      unless uploaded_io.nil?
        file_path = Rails.root.join('tmp', 'course_item_temp.xlsx')
        File.open(file_path, 'wb') do |file|
          file.write(uploaded_io.read)
        end
        require 'roo'
        s = Roo::Spreadsheet.open(file_path.to_s)
        s.default_sheet = s.sheets.first # first sheet in the spreadsheet file will be used
        row_index = 0;
        s.first_row.upto(s.last_row) do |row|
          if row_index == 0
            row_index = 1
            next
          end
          s.cell(row,1) # returns the content of the first row/first cell in the sheet
          ci = {:course_id => id, :question => s.cell(row,1), :answer => s.cell(row,2), :filename => s.cell(row,3), :day => s.cell(row,4)}
          course_item = CourseItem.new(ci)
          course_item.save!
          row_index = row_index + 1
        end
        File.delete(file_path.to_s)
      end

      uploaded_io = params[:course][:course_items_audio_zip_file]
      cmd = ""
      unless uploaded_io.nil?
        file_path = Rails.root.join('tmp', 'course_item_audio_temp.zip')
        File.open(file_path, 'wb') do |file|
          file.write(uploaded_io.read)
        end
        destination = Rails.root.join('public', 'files', 'audio')
        cmd = "unzip -jn " + file_path.to_s + " -d " + destination.to_s
        wasGood = system( cmd )
        File.delete(file_path.to_s)
      end
      redirect_to @course, notice: t('create_course_successful')
    else
      render action: 'new', notice: @course.errors
    end
    
  end

  # PATCH/PUT /admin/courses/1
  def update
    if @course.update(course_params)
      redirect_to courses_url, notice: 'Course was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /admin/courses/1
  def destroy
    @course.destroy
    redirect_to courses_url, notice: 'Course was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_course
      @course = Course.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def course_params
      if(params[:course][:category_id] == '' && !params[:category][:title].blank?)
        cat = Category.new(params[:category])
        cat.save!
        params[:course][:category_id] = cat.id
      end
      params.require(:course).permit(:id, :serial, :category_id, :briefing, :description, :price, :title, :unit, :duration_days, :start_at, :end_at, :due_at)
    end
end

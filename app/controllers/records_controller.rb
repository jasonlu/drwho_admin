class RecordsController < ApplicationController
  before_filter :record_section, :only => [:index, :show, :wrong_list_show]
  before_filter :wrong_list_section, :only => [:wrong_list_index, :wrong_list_question]

  def record_section
    @nav_section = "records"
  end

  def wrong_list_section
    @nav_section = "wrong_list"
  end
  
  def index
    sort = params[:sort]
    dir = params[:dir]

    case sort
    when 'fullname'
    when 'score'
    when 'passed'
    when 'starts_at'
    when 'ends_at'
    when 'title'
      sort = 'courses.title'
    when 'category'
      sort = 'categories.title'
    when 'serial_id'
      sort = 'user_id'
    when 'unit'
      sort = 'courses.unit'
    when 'serial'
      sort = 'courses.serial'
    else
      sort = 'starts_at'
      params[:sort] = 'starts_at'
      prepare_sorting
    end

    #params[:search] ||= Hash.new
   
    if !params[:search].is_a? Hash
      params[:search] = Hash.new
    end
    
    @studies = Study.joins(:user => :user_profile).joins(:course => :category).
    select("
      CONCAT(user_profiles.lastname, user_profiles.firstname) as fullname,
      lastname,
      firstname,
      studies.*
    ").
    order(sort + " " + dir).
    page(params[:page])

    @studies = @studies.where("
      user_profiles.lastname LIKE ? OR
      user_profiles.firstname LIKE ? OR
      CONCAT(user_profiles.lastname, ' ', user_profiles.firstname) LIKE ?",
      "%" + params[:search][:name] + "%",
      "%" + params[:search][:name] + "%",
      "%" + params[:search][:name] + "%"
    ) unless params[:search][:name].blank?

    unless params[:search][:date_start].try(:to_date).nil?
      date_start = params[:search][:date_start].to_date
    else
      date_start = '2000-01-01'.to_date
    end

    unless params[:search][:date_end].try(:to_date).nil?
      date_end = params[:search][:date_end].to_date
    else
      date_end = '2030-12-31'.to_date
    end

    @studies = @studies.where("
      NOT (starts_at > ? OR
      ends_at < ?)",
      date_end,
      date_start
    )
    render 'index'
  end

  def show
    
    @study = Study.find(params[:study_id])
    
    @gpa = 0.0
    #@story_records.each |rec| do
    #end
    if @study.score.nil?
      @gpa = @study.progresses.where('stage = 3').select("AVG(score) AS gpa").first.gpa
    else 
      @gpa = @study.score
    end
    @records = @study.study_records 

  end


  def wrong_list_index
    params['search'] = Hash.new if params['search'].nil?
    @category_all = Category.all
    @category = Category.find(params[:search][:category_id]) unless params[:search][:category_id].blank?

    if params['search']['category_id'].blank? or params['search']['course_title'].blank?
      params['search']['course_title'] = ""
      params['search']['unit'] = ""
    end
    params['search']['course_title'] = "" if params['search']['course_title'].nil?
    @course_titles = Course.where(:category_id => params['search']['category_id'])
    @course_units = Course.where(:title => params['search']['course_title']).group(:unit) 

    sort = params[:sort]
    dir = params[:dir]

    case sort
    when 'category'
      sort = 'categories.title'
    when 'title'
      sort = 'courses.title'
    when 'unit'
      sort = 'courses.unit'
    when 'cnt'
      sort = 'cnt'
    else
      sort = 'cnt'
    end
    
    @records = StudyRecord.joins(:course => :category).joins(:course_item).select('course_item_id, count(*) AS cnt, study_records.course_id, study_id').where(:wrong => true).group('course_item_id').order(sort + ' ' + dir).page(params[:page])
    @records = @records.where('courses.category_id = ?', params['search']['category_id']) unless params['search']['category_id'].blank?
    @records = @records.where('courses.title = ?', params['search']['course_title']) unless params['search']['course_title'].blank?
    @records = @records.where('courses.unit = ?', params['search']['unit']) unless params['search']['unit'].blank?

    render "wrong_list_index"
    
  end

  def wrong_list_show
    sort = params[:sort]
    dir = params[:dir]

    case sort
    when 'question'
      sort = 'course_items.question'
    when 'cnt'
      sort = 'cnt'
    else
      sort = 'cnt'
      params[:sort] = 'cnt'
      prepare_sorting
    end

    @study = Study.find(params[:study_id])
    @user = @study.user
    @records = @study.records.wrong.order(sort + " " + dir).page(params[:page])
  end

  def wrong_list_question
    sort = params[:sort]
    dir = params[:dir]

    case sort
    when 'fullname'
      sort = 'user_profiles.lastname'
    when 'id'
      sort = 'users.id'
    when 'cnt'
      sort = 'cnt'
    else
      sort = 'cnt'
      params[:sort] = 'cnt'
      prepare_sorting
    end

    @records = StudyRecord.joins(:user => :user_profile).joins(:course => :category).joins(:course_item).select('course_item_id, count(*) AS cnt, study_records.course_id, study_records.user_id').where(:wrong => true, "course_item_id" => params[:course_item_id]).group('study_records.user_id').order(sort + ' ' + dir).page(params[:page])
    @course_item = CourseItem.find(params[:course_item_id])
    @course = @course_item.course
  end

  
end

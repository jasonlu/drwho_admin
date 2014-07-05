class StudiesController < ApplicationController
  #before_filter :set_users, :only => [:set_start_day, :record, :wrong_list]
  
  # GET /studies
  # GET /studies.json
  def index
    sort = params[:sort]
    dir = params[:dir]

    case sort
    when 'category'
      sort = 'categories.title'
    when 'title'
      sort = 'courses.title'
    when 'unit'
      sort = 'courses.unit'
    when 'serial'
      sort = 'courses.serial'
    when 'starts_at', 'ends_at'
    else
      sort = 'starts_at'
    end

    @studies = Study.where('user_id = ? AND starts_at <= ?', current_admin.id, Time.zone.today).joins(:course).joins(:category).order(sort + ' ' + dir).page(params[:page])
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @studies }
    end
  end

  # GET /studies/1
  # GET /studies/1.json
  def show
    @study = Study.find(params[:id])  
    @gpa = @study.progresses.where('stage = 3').select("AVG(score) AS gpa").first.gpa
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @study }
    end
  end

  def destroy
    @study = Study.find(params[:id])  
    @study.user_id = 0
    @study.save
    flash[:notice] = "刪除記錄成功"
    redirect_to :back;
  end

  
  def set_start_day
    params[:search] ||= Hash.new
    @nav_section = "set_start_day"
    sort = params[:sort]
    dir = params[:dir]

    case sort
    when 'category'
      sort = 'categories.title'
    when 'title'
      sort = 'courses.title'
    when 'unit'
      sort = 'courses.unit'
    when 'serial'
      sort = 'courses.serial'
    when 'starts_at', 'ends_at', 'order_number'
    when 'id'
      sort = 'studies.user_id'
    when 'fullname'
      sort = 'lastname'
    else
      sort = 'starts_at'
    end

    search = params[:search]
    
    @studies = Study.
      joins(:course => :category).
      joins(:user => :profile).
      joins(:user_order).
      order(sort + ' ' + dir).
      page(params[:page])

    if search[:no_date].to_i == 1
      @studies = @studies.where("starts_at IS NULL")
    else
      @studies = @studies.where("starts_at >= ?", search[:date_start].to_date) unless search[:date_start].blank?
      @studies = @studies.where("starts_at <= ?", search[:date_end].to_date) unless search[:date_end].blank?
    end
    @studies = @studies.where("studies.user_id = ?", search[:serial_id].to_i - 1000065535) if search[:serial_id].to_i > 0
    @studies = @studies.where("
      user_profiles.lastname LIKE ? OR 
      user_profiles.firstname LIKE ? OR 
      CONCAT(user_profiles.lastname, ' ', user_profiles.firstname) LIKE ? OR
      CONCAT(user_profiles.lastname, user_profiles.firstname) LIKE ?
      ", 
      "%" + search[:name] + "%", 
      "%" + search[:name] + "%", 
      "%" + search[:name] + "%",
      "%" + search[:name] + "%") unless search[:name].blank?
  end

  # PATCH
  def update_start_day
    @study = Study.find(params[:study_id])
    @study.starts_at = params[:starts_at]
    @study.ends_at = @study.starts_at + @study.course.duration_days - 1
    @study.save if params[:save] == 'true'
    render :json => @study
  end

  private
  def set_users
    sort = params[:sort]
    dir = params[:dir]

    case sort
    when 'firstname'
      sort = 'user_profiles.firstname'
    when 'firstname'
      sort = 'user_profiles.lasttname'
    when 'serial'
      sort = 'id'
    when 'email'
    else
      sort = 'id'
    end

    @users = User.where("type != 'Admin' OR type is NULL").joins(:user_profile).order(sort + ' ' + dir).page(params[:page])
  end
end
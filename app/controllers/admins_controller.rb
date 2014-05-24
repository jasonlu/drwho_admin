class AdminsController < ApplicationController


  # GET /admin/users
  def index
    sort = params[:sort]
    dir = params[:dir]

    case sort
    when 'firstname'
      sort = 'user_profiles.firstname'
    when 'lasttname'
      sort = 'user_profiles.lasttname'
    when 'gender'
      sort = 'user_profiles.gender'
    when 'dob'
      sort = 'user_profiles.dob'
    when 'dob_month'
      sort = 'MONTH(user_profiles.dob)'
    when 'education'
      sort = 'user_profiles.education'
    when 'country'
      sort = 'user_profiles.country'
    when 'serial'
      sort = 'id'
    when 'email'
      sort = 'email'
    when 'activated'
      sort = 'confirmed_at'
    else
      sort = 'id'
    end
    puts "sort: " + sort
    model = controller_name.classify
    
    @users = Admin.joins(:profile).order(sort + ' ' + dir).group("admins.id").page(params[:page])    
    render 'index', :locals => {:sort => sort, :dir => dir}
  end

  def new
    @user = Admin.new
  end

  def create
    puts admin_params
    @user = Admin.new(admin_params)
    

    if @user.save
      flash[:notice] = t('devise.registrations.new_admin', :email => @user.email)
      redirect_to admins_path
    else
      flash[:error] = t('devise.failure.invalid')
      redirect_to :back
      
    end
    
    #flash[:notice] = t('my_error_message', :problem => 'Big Problem')
    

  end


private
  def admin_params
    params.require(:admin).permit(:id, :email, :password, :password_confirmation)

  end





end
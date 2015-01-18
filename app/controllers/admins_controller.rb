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
    
    @users = Admin.includes(:profile).order(sort + ' ' + dir).group("admins.id").page(params[:page])    
    render 'index', :locals => {:sort => sort, :dir => dir}
  end

  def new
    @user = Admin.new
  end

  def show
    @user = Admin.find(params[:id])
  end

  def create
    @user = Admin.new(admin_params)
    
    if @user.save
      flash[:notice] = t('devise.registrations.new_admin', :email => @user.email)
      redirect_to admins_path
    else
      flash[:error] = t('devise.failure.invalid')
      redirect_to :back
    end
  end

  def edit
    @user = Admin.find(params[:id])
    if @user.profile.nil?
      @profile = @user.build_profile
      @profile.save
    end
  end

  def update
    @user = Admin.find(params[:id])
    
    
    new_params = admin_params
    if params[:admin][:activated].to_i == 1 and @user.confirmed_at.nil?
      @user.confirmed_at = DateTime.now
      @userconfirmation_token = nil
    end
    new_params[:password] = nil
    new_params[:password] = params[:admin][:password] unless params[:admin][:password].blank?
    if @user.update(new_params)
      flash[:notice] = t('devise.registrations.updated', :email => @user.email)
      #render json: params
      redirect_to :back
    else
      render action: 'edit'
    end
  end

  def destroy
    @user = Admin.find(params[:id])
    @user.destroy
    flash[:notice] = t('devise.registrations.destroyed', :email => @user.email)
    redirect_to :back
  end


private
  def admin_params
    params.require(:admin).permit(:id, :email, :password, :password_confirmation, :roles => [], :user_profile_attributes => [:firstname, :lastname, :id_number, :dob, :gender, :education, :country, :register_address, :address])
  end

end
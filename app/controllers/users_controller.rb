class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]

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
    if(model == 'Admin') 
      @user = User.where("type = 'Admin'")
    else
      @user = User.where("type = 'User' OR type is NULL")
    end
    @users = @user.joins(:user_profile).order(sort + ' ' + dir).page(params[:page])    
    render 'index', :locals => {:sort => sort, :dir => dir}
  end

  def show
  end

  def new
    @user = User.new
    @user.build_user_profile
    #@user.profile.new
  end

  def edit
    #@user.profile
  end

  def create
    @user = User.new(user_params)
    if @user.save
      #redirect_to @user, notice: 'User was successfully created.'
      render :json => @user
      #redirect_to users_path, notice: 'User was successfully updated.'
    else
      #redirect_to
      #render action: 'new'
      render :json => @user
    end
  end

  def update
    model = controller_name.classify.downcase
    @user.password = params[model.to_sym][:password] unless params[model.to_sym][:password].blank?
      
    if params[model.to_sym][:activated].to_i == 1 and @user.confirmed_at.nil?
      @user.confirmed_at = DateTime.now
      @userconfirmation_token = nil
    end
    
    if @user.update!(user_params)
     User.where("roles_mask IS NULL OR roles_mask = 0").update_all(:type => 'User')
     User.where("roles_mask > 0").update_all(:type => 'Admin')
      flash[:notice] = "#{model} was successfully updated."
      redirect_to :controller => controller_name, :action => 'index'
      #render :nothing => true;
    else
      render action: 'edit'
    end
  end

  def search
    keyword = params[:keyword].to_s
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

    keyword = "%#{keyword}%"
    model = controller_name.classify
    profiles = UserProfile.where("
      lastname LIKE ? OR 
      firstname LIKE ? OR 
      education LIKE ? OR 
      country LIKE ? OR 
      register_address LIKE ? OR 
      address LIKE ? OR 
      cellphone LIKE ? OR 
      phone LIKE ? OR 
      gender LIKE ?", 
      keyword, 
      keyword, 
      keyword, 
      keyword, 
      keyword, 
      keyword, 
      keyword, 
      keyword, 
      keyword).select("user_id")
    ids = Array.new
    profiles.each do |p|
      ids.push p.user_id
    end
    @users = User.where("(email LIKE ? OR id IN (?))", keyword, ids)
    if model == 'Admin'
      @users.where("type = 'Admin'")
    else
      @users.where("type IS NULL OR type = '' OR type = 'User'")  
    end
    
    @users = @users.page(params[:page])
    render 'index', :locals => {:sort => sort, :dir => dir}
  end

  # DELETE /admin/users/1
  def destroy
    
    @user.destroy
    
    redirect_to :action => 'index', notice: 'User was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def user_params
      params.require(:user).permit(:id, :email, :roles => [], user_profile_attributes: [:id, :firstname, :lastname, :id_number, :dob, :gender, :education, :country, :register_address, :address])
      #params[:user]
    end
end

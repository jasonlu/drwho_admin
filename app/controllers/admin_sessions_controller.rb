class AdminSessionsController < Devise::SessionsController
  skip_before_filter :authenticate_user!
  layout "login"

  # def new
  #   self.resource = resource_class.new(sign_in_params)
  #   clean_up_passwords(resource)
  #   render "/admin/devise/sessions/new", :resource => resource
  # end
# 
  # #def after_sign_in_path_for(resource)
  #   
  #   #admin_root_url
# 
  # #end
# 
  # # POST /resource/sign_in
  # def create
  #   self.resource = warden.authenticate!(auth_options)
  #   set_flash_message(:notice, :signed_in)
  #   sign_in(resource_name, resource)
  #   yield resource if block_given?
  #   #respond_with resource, location: after_sign_in_path_for(resource)
  #   redirect_to "/admin/"
  # end


end
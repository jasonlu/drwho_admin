class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :white_list

  before_filter :authenticate_admin!
  before_filter :load_config
  before_filter :prepare_sorting

  layout "application"
  @nav_section = ""  


  def white_list
    @ips = Rails.application.config.white_list
    if not @ips.include? request.remote_ip
       # Check for your subnet stuff here, for example
       # if not request.remote_ip.include?('127.0,0')
       render :text => "You are unauthorized"
       return
    end
  
  end
  def prepare_sorting
    params[:sort] = 'id' if params[:sort].blank?
    sort = params[:sort]
    params[:sort] = params[:sort].sub(/-/, '_')
    params[:dir] = 'desc' if params[:dir].blank?
    dir = params[:dir]    
    sorting_class = sort.downcase.split('.').last + '_' + dir.downcase
    @sorting_class = sorting_class
  end

  def load_config

    site_configs = SiteConfig::all
    @config = Hash.new
    site_configs.each do |config|

      @config[config.key.to_sym] = config.value

    end

  end

  def current_user
    return current_admin
  end

end

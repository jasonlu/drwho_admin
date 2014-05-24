class SiteConfigsController < ApplicationController

  def index
    
  end

  def update
    params.each do |key, value|
      case key
      when 'utf8', '_method', 'authenticity_token'
        next
      end
      config = SiteConfig.find_by_key(key)
      unless config.nil?
        config.update_attribute('value', value) unless config.nil?
      else
        SiteConfig.create(:key => key, :value => value)
      end
    end

    redirect_to url_for(:controller => 'site_configs', :action => 'index')
  end
end

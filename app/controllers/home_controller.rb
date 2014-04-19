class HomeController < ApplicationController

  def dashboard
    
  end

  def edit
    path = File.join(Rails.root, "public", "docs", "mfg.html")
    if File.file?(path)
      File.open(path, "r+") do |f|
        @mfg = f.read
      end
    else
      @mfg = ""
    end
  end

  def update

    path = File.join(Rails.root, "public", "docs", "mfg.html")
    File.open(path, "w+") do |f|
      f.write(params[:content])
    end
    redirect_to :back
  end

end

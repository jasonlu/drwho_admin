class AdsController < ApplicationController
  before_action :set_ad, only: [:show, :edit, :update, :destroy]

  # GET /ads
  def index
    @ads = Ad.all
  end

  # GET /ads/1
  def show
  end

  # GET /ads/new
  def new
    @ad = Ad.new
  end

  # GET /ads/1/edit
  def edit
    
  end

  # POST /ads
  def create
    @ad = Ad.new(ad_params)

    if @ad.save
      redirect_to ads_path, notice: 'Ad was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /ads/1
  def update
    if @ad.update(ad_params)
      redirect_to ads_path, notice: 'Ad was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /ads/1
  def destroy
    @ad.destroy
    redirect_to ads_path, notice: 'Ad was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ad
      @ad = Ad.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def ad_params
      file = params[:ad][:image]
      unless file.nil?
        name =  file.original_filename
        directory = "public/uploads"
        # create the file path
        path = File.join(directory, name)
        # write the file
        File.open(path, "wb") { |f| f.write(params[:ad][:image].read) }
        image_url = '/uploads/' + name 
        params[:ad][:content] = "<img src='#{image_url}' >"
      end
      
      params.require(:ad).permit(:content, :weight, :link, :counter, :location)
    end
end

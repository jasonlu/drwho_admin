class UploadFilesController < ApplicationController
  before_action :set_upload_file, only: [:show, :edit, :update, :destroy]
  skip_before_action :verify_authenticity_token, only: [:create]
  layout "blank"
  

  # GET /upload_files
  def index
    accepted_formats = [".jpg", ".png"]
    upload_folder = Rails.root.join('public', 'uploads')
    @upload_files = Array.new
    Dir.entries(upload_folder).select do |entry|
      if !File.directory? File.join(upload_folder,entry) and accepted_formats.include? File.extname(entry)
        fileObj = Hash.new
        fileObj[:path] = File.join("/uploads",entry) 
        @upload_files.push fileObj
      end
    end
    #@upload_files = UploadFile.all
  end

  # GET /upload_files/1
  def show
  end

  # GET /upload_files/new
  def new
    @upload_file = UploadFile.new
  end

  # GET /upload_files/1/edit
  def edit
  end

  # POST /upload_files
  def create
    upload_path = Rails.application.config.upload_path
    file = params[:upload]
    unless file.nil?
      name =  file.original_filename
      #directory = "public/uploads"
      # create the file path
      path = File.join(upload_path, name)
      # write the file
      File.open(path, "wb") { |f| f.write(params[:upload].read) }
      image_url = '/uploads/' + name
      @CKEditorFuncNum = params[:CKEditorFuncNum]
      @image_url = image_url
      @message = "Upload completed."
      
    end



    #@upload_file = UploadFile.new(upload_file_params)

    #if @upload_file.save
    #  redirect_to @upload_file, notice: 'Upload file was successfully created.'
    #else
    #  render action: 'new'
    #end
  end

  # PATCH/PUT /upload_files/1
  def update
    if @upload_file.update(upload_file_params)
      redirect_to @upload_file, notice: 'Upload file was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /upload_files/1
  def destroy
    @upload_file.destroy
    redirect_to upload_files_url, notice: 'Upload file was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_upload_file
      @upload_file = UploadFile.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def upload_file_params
      params.require(:upload_file).permit(:title, :type, :path, :size)
    end
end

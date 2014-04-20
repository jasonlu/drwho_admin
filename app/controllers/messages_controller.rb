class MessagesController < ApplicationController
  before_action :set_message, only: [:show, :edit, :update, :destroy]
  

  # GET /admin/messages
  def index
    sort = params[:sort]
    dir = params[:dir]
    case sort
    when 'sender'
      sort = 'user_profiles.lastname'
    when 'subject', 'created_at'
    else
      sort = 'id'
    end
    @messages = Message.all.joins(:sender_profile).order(sort + ' ' + dir).page(params[:page])
  end

  # GET /admin/messages/1
  def show
  end

  # GET /admin/messages/new
  def new
    @message = Message.new
  end

  # GET /admin/messages/1/edit
  def edit
  end

  # POST /admin/messages
  def create
    @message = Message.new(message_params)
    @receiver_users = nil
    if @receivers.include?('everyone')
      #@receiver_users.push(User.everyone)
      @receiver_users = User.everyone
    else
      @receivers.each do |receiver| 
        @receiver_users = User.send(receiver)
      end
    end
    
    if @message.save
      message_id = @message.id
      @receiver_users.each do |user|
        puts user.id
        inbox = Inbox.new
        inbox.user_id = user.id
        inbox.message_id = message_id
        inbox.read = 0
        inbox.save
        
      end
      redirect_to messages_path, notice: 'Message was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /admin/messages/1
  def update
    if @message.update(message_params)
      redirect_to messages_path, notice: 'Message was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /admin/messages/1
  def destroy
    @message.destroy
    redirect_to messages_url, notice: 'Message was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_message
      @message = Message.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def message_params
      @receivers = params[:receivers]
      params[:message][:user_id] = current_user.id
      params.require(:message).permit(:id, :subject, :content, :user_id)
    end

    def male
      
      ids = UserProfile.where("gender = 1").select(:user_id)
      ids = ids.map{|user| user.user_id}
      @receiver_ids.push(ids)
      
    end

    def female
      ids = UserProfile.where("gender = 0").select(:user_id)
      ids = ids.map{|user| user.user_id}
      @receiver_ids.push(ids)
    end

    def birthday_person
      month = Time.now.month
      month = month < 10 ? 0.to_s + month.to_s : month.to_s
      month = "%-#{month}-%"
      ids = UserProfile.where("dob LIKE ?", month).select(:user_id)
      if ids.nil?
        return
      else
        ids = ids.map{|user| user.user_id}
        @receiver_ids.push(ids)
      end
      
    end

    def everyone
      ids = UserProfile.all.select(:user_id)
      ids = ids.map{|user| user.user_id}
      @receiver_ids = ids

    end

end

class OrdersController < ApplicationController
  before_action :set_order, only: [:show, :edit, :update, :destroy]

  # GET /admin/orders
  def index
    
    sort = params[:sort]
    dir = params[:dir]

    case sort
    when 'fullname'
      sort = 'user_profiles.lastname'
    when 'payment_status', 'payment_price', 'order_number'
    else
      sort = 'id'
    end

    @orders = UserOrder.joins(:user => :user_profile).where.not(:payment_method => -1).order(sort + ' ' + dir).page(params[:page])
  end

  # GET /admin/orders/1
  def show
  end

  # GET /admin/orders/new
  def new
    @order = UserOrder.new
  end

  # GET /admin/orders/1/edit
  def edit
  end

  # POST /admin/orders
  def create
    @order = UserOrder.new(order_params)

    if @order.save
      redirect_to @order, notice: 'Order was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /admin/orders/1
  def update
    if @order.update(order_params)
      make_paid(@order.id) if @order.payment_status == 1

      redirect_to edit_order_path(@order), notice: 'Order was successfully updated.'
    else
      #render action: 'edit'
    end
  end

  # PATCH/PUT /admin/orders/1
  def quickpaid
    id = params[:id]
    @order = UserOrder.find(id)
    if @order.update_attribute(:payment_status, 1)
      make_paid(id)
      redirect_to orders_path, notice: 'Order was successfully updated.'
    else
      #render action: 'edit'
    end
  end

  # DELETE /admin/orders/1
  def destroy
    @order.destroy
    redirect_to orders_url, notice: 'Order was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = UserOrder.find(params[:id])
      @user = @order.user
      @courses = Course.find(@order.courses.split(','))
    end

    # Only allow a trusted parameter "white list" through.
    def order_params
      params.require(:user_order).permit(:payment_status, :payment_price, :note)
    end

    def make_paid(order_id)
      order = UserOrder.find(order_id)
      user_id = order.user_id
      courses = order.course_list

      courses.each do |course|
        study = Study.create(:user_id => user_id, :user_order_id => order_id, :course_id => course.id)
      end

    end

end

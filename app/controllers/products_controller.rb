class ProductsController < ApplicationController
  http_basic_authenticate_with name: STORE['admin_user'], password: STORE['admin_pass'], except: [:subscribe, :index, :show, :order]

  def subscribe
    sub = Subscription.new(subscription_params)
    redirect_to root_url, notice: (sub.save ? "Subscribed!" : "Invalid entry.")
  end

  def index
    @products = Product.categories
  end

  def show
    @product = Product.find(params['id'])
    if @product.children.size == 1
      redirect_to @product.children.first
    else
      @order = @product.new_order
    end
  end

  def order
    @order = Order.new(order_params.merge(
      :ip            => request.remote_ip, 
      :referrer_acct => cookies[:referer], 
      :bts_asset_id  => session[:asset]))

    if @order.save
      redirect_to @order
    else
      @product = @order.product
      render 'show'
    end
  end


  def report
  end

  def new
    @product = Product.new(:parent_id => params[:id])
  end

  def create
    @product = Product.new(product_params)
    if @product.save
      redirect_to @product, notice: "All good!"
    else
      render 'new'
    end
  end

  def edit
    @product = Product.find(params['id'])
  end

  def update
    @product = Product.find(params['id'])
    if @product.update_attributes(product_params)
      redirect_to edit_product_url, notice: "All good!"
    else
      render 'edit'
    end
  end

private

  def subscription_params
    params.require(:subscription).permit(:email)
  end

  def order_params
    params.require('order').permit(:product_id, :shipping_id, :address, :email)
  end

  def product_params
    params.require('product').permit(:name, :desc, :parent_id,
       :cents, :position, :default_id, :dl, :image, :is_category, :code, :short_desc,
       :button_label, :num_stock, :num_sold, :node_type, :royalty_acct, :royalty_cents, :refer_cents, 
       :photos_attributes => [:image, :_destroy, :id])
  end
end

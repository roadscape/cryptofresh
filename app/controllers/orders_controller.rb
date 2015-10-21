class OrdersController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_filter :load_order

  layout 'fresh'

  def show
    render 'stale' if @order.stale?
  end

  def status
    Wallet.scan

    render :js => case
      when @order.paid? && @order.is_dd?
        "notify_dl('#{download_order_url(@order)}');"
      when @order.paid?
        "notify_ship();"
      else
        ""
    end
  end

  def download
    raise "Order is stale"    if @order.stale?
    raise "Order is not paid" unless @order.paid?
    raise "Not downloadable"  unless @order.is_dd?

    p = @order.product
    send_file p.dl.path,
      :filename    => p.dl_file_name,
      :type        => p.dl_content_type,
      :disposition => 'attachment'
  end

private
  def load_order
    @order = Order.from_param(params[:id])
  end
end

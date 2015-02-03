class OrdersController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_filter :load_order

  def show
    render 'expired' if @order.expired?
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
    raise "Order is too far expired" if @order.due_at < 12.hours.ago
    raise "Order has not been paid"  unless @order.paid?
    raise "Order is not a download"  unless @order.is_dd?

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

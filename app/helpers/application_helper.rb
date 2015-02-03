module ApplicationHelper

  def local_price obj, show_full = false
    amt = obj.amount.convert(session[:asset])
    out = show_full ? amt.full : amt.short
    out.sub!(/.00(?=[^\d])/, '')
    out = out.sub("oz", "<sub>oz</sub>").html_safe if show_full
    out
  end

  def bootstrap_class_for(flash_type)
    { :success => 'alert-success',
      :error   => 'alert-danger',
      :alert   => 'alert-warning',
      :notice  => 'alert-info'
    }[flash_type.to_sym]
  end

end

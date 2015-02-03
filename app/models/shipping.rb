class Shipping < ActiveRecord::Base
  def amount
    Amount.cent(cents)
  end
end

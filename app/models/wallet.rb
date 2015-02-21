class Wallet
  ACCT = STORE['cashier_acct']

  # Checks all open orders vs all incoming payments
  def self.scan
    open_orders = Order.where(:paid_at => nil).where('due_at > ?', 2.hours.ago)
    Wallet.new_entries.each do |tx|
      order = open_orders.find{|o| tx['memo'].include?(o.pub_id)}
      next unless order && !order.paid_at
      next unless Amount.from_bts(tx['amount']).includes?(order.amount)
      order.update_attributes(:paid_at => DateTime.now, :trx_id => tx['trx_id'])
    end
  end


  def self.new_entries
    out = []
    BitShares::API::Wallet.account_transaction_history.each do |tx_data|
      tx = Tx.cache(tx_data)
      out += tx.ledger_entries.select{|f| f['to'] == ACCT && f['from'] != ACCT}
    end
    out
  end

end

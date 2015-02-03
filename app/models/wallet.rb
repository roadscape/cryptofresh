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
    BitShares::API::Wallet.account_transaction_history.each do |tx|
      #next if Tx.find_by_trx_id(tx['trx_id'])
      Tx.find_by_trx_id(tx['trx_id']) || Tx.create(
       :block_num => tx['block_num'], 
       :trx_id    => tx['trx_id'],
       :json      => tx.to_json)

      out += Wallet.clean_tx(tx).select{|f| f['to'] == ACCT && f['from'] != ACCT}
    end
    out
  end

  def self.clean_tx tx
    raise "UNHANDLED CASE" unless tx.delete("is_market")        == false
    raise "UNHANDLED CASE" unless tx.delete("is_market_cancel") == false
    raise "UNHANDLED CASE" unless tx.delete("is_virtual")       == false
    raise "UNHANDLED CASE" unless tx.delete("error")            == nil
    raise "UNHANDLED CASE" unless tx.delete("is_confirmed")     == true

    tx['date']    = bts_date(tx.delete('timestamp'))
    tx['expires'] = bts_date(tx.delete('expiration_timestamp'))
    tx['fee']     = tx['fee']
    entries       = tx.delete("ledger_entries")
    unhandled     = tx.keys - %w{trx_id block_num date expires fee}
    raise "Unhandled keys: #{unhandled.join(', ')} -- #{tx.inspect}" if unhandled.any?
    raise "Multiple ledger entries" if entries.size != 1

    out = []
    entries.each do |e|
      e.delete('running_balances')
      e['from'] = e.delete('from_account')
      e['to']   = e.delete('to_account')
      out << tx.merge(e) #unless e['from'] == e['to']
    end
    out
  end

private

  def self.bts_date ts
    DateTime.parse(ts).to_time.localtime("-06:00").strftime("%Y-%m-%d %H:%M:%S")
  end

end

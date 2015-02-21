class Tx < ActiveRecord::Base
  validates_presence_of     :block_num, :trx_id, :json
  validates_numericality_of :block_num

  # Given a single transaction-row from the API, 
  #   make sure we have it saved, and
  #   return it in a Tx object wrapper
  def self.cache(tx_data)
    Tx.find_by_trx_id(tx_data['trx_id']) || Tx.create(
       :block_num => tx_data['block_num'],
       :trx_id    => tx_data['trx_id'],
       :json      => tx_data.to_json)
  end

  def raw
    @raw ||= JSON::parse(json)
  end

  def raw=(hash)
    @raw = hash
    self.json = hash.to_json
  end

  def ledger_entries
    tx = raw
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

  def bts_date ts
    DateTime.parse(ts).to_time.localtime("-06:00").strftime("%Y-%m-%d %H:%M:%S")
  end
end

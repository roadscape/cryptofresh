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

  # This method is really paranoid and will hopefully break right away
  #   if any of my assumptions about the API interface are broken.
  def ledger_entries
    tx = raw

    # Delete keys that have expected values.
    raise "UNHANDLED CASE" unless tx.delete("is_market")        == false
    raise "UNHANDLED CASE" unless tx.delete("is_market_cancel") == false
    raise "UNHANDLED CASE" unless tx.delete("is_virtual")       == false
    raise "UNHANDLED CASE" unless tx.delete("error")            == nil
    raise "UNHANDLED CASE" unless tx.delete("is_confirmed")     == true

    # Clean up the keys. Build a minimal hash of reference data.
    ref = {
      'date'      => bts_date(tx.delete('timestamp')),
      'expires'   => bts_date(tx.delete('expiration_timestamp')),
      'fee'       => tx.delete('fee'),
      'trx_id'    => tx.delete('trx_id'),
      'block_num' => tx.delete('block_num')}

    # The only remaining key is removed. The hash should be empty!
    entries = tx.delete("ledger_entries")
    raise "Unhandled keys! #{tx.inspect} -- ref: #{ref}" if tx.keys.any?

    # TODO: Another assumption. Have not yet seen more than 1 entry in a tx.
    #raise "Multiple ledger entries in trx #{ref['trx_id']}\n#{entries.inspect}" if entries.size != 1

    # Append the minimal hash of data to each ledger entry
    # TODO: Document and sanity-check the structure of ledger_entries
    entries.map do |e|
      e.delete('running_balances')
      e['from'] = e.delete('from_account')
      e['to']   = e.delete('to_account')
      ref.merge(e)
    end
  end

private

  def bts_date ts
    DateTime.parse(ts).to_time.localtime("-06:00").strftime("%Y-%m-%d %H:%M:%S")
  end
end

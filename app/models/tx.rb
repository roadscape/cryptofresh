class Tx < ActiveRecord::Base
  validates_presence_of     :block_num, :trx_id, :json
  validates_numericality_of :block_num

  # Given a single transaction-row from the API, 
  #   make sure we have it saved, and
  #   return it in a Tx object wrapper
  def self.cache(tx_data)
    trx_id    = tx_data['op']['id']
    block_num = tx_data['op']['block_num']

    Tx.find_by_trx_id(trx_id) || Tx.create!(
       :block_num => block_num,
       :trx_id    => trx_id,
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
  def ledger_entry
    tx = raw

    return ledger_entry_legacy if legacy?

    memo  = tx.delete('memo')
    desc  = tx.delete('description')
    opx   = tx.delete('op')
    raise "UNHANDLED DATA: #{tx}" unless tx.empty?

    id    = opx['id']
    block = opx['block_num']
    code  = opx['op'][0]
    op    = opx['op'][1]
    raise "UNKNOWN CODE: #{code}--#{op}" unless code == 0

    # Clean up the keys. Build a minimal hash of reference data.
    op.delete('memo')
    op.delete('extensions')
    date = Graphene::API::RPC.instance.get_block(block)['timestamp']
    ref  = {
      'trx_id'    => id,
      'block_num' => block,
      'memo'      => memo,
      'date'      => bts_date(date),
      'expires'   => bts_date(date),
      'fee'       => op.delete('fee'),
      'amount'    => op.delete('amount'),
      'from'      => op.delete('from'),
      'to'        => op.delete('to')}

    # The only remaining key is removed. The hash should be empty!
    raise "UNHANDLED DATA: #{op}" unless op.empty?

    ref
  end

private

  def bts_date ts
    DateTime.parse(ts).to_time.localtime("-06:00").strftime("%Y-%m-%d %H:%M:%S")
  end

  def legacy?
    !raw['is_market'].nil?
  end

  # Legacy adapter! Any BTS 0.9x transactions are fed thru here.
  def ledger_entry_legacy
    tx = raw

    # warn that we threw away ledger entries [1..-1] (rare. ok for legacy compat)
    multi = (tx['ledger_entries'].size != 1)
    note  = " #{multi ? '[WARN]' : ''}[LEGACY]"

    { 'date'      => bts_date(tx['timestamp']),
      'expires'   => bts_date(tx['expiration_timestamp']),
      'fee'       => tx['fee'],
      'trx_id'    => tx['trx_id'],
      'block_num' => tx['block_num'],
      'from'      => tx['ledger_entries'][0]['from_account'],
      'to'        => tx['ledger_entries'][0]['to_account'],
      'amount'    => tx['ledger_entries'][0]['amount'],
      'memo'      => tx['ledger_entries'][0]['memo'] + note }
  end

end

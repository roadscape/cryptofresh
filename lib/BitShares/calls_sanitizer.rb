require 'json'

module BitShares
  class CallsSanitizer

    attr_reader :wallet_api, :network_api, :blockchain_api, :general_api

    RESTRICTED_CALLS = %w(
      wallet_open
      wallet_unlock
      wallet_create
      wallet_get_name
      wallet_close
      wallet_set_transaction_expiration_time
      wallet_remove_transaction
      wallet_change_passphrase
      wallet_account_create
      wallet_burn
      wallet_delegate_withdraw_pay
      wallet_set_transaction_fee
      wallet_set_setting
      wallet_delegate_set_block_production
      wallet_set_transaction_scanning
      wallet_recover_accounts
      wallet_verify_titan_deposit
      wallet_list
      wallet_list_accounts
      wallet_list_my_accounts
      wallet_account_list_public_keys
      open
      close
      unlock
      quit
      stop
      execute_command_line
      execute_script
      rpc_set_username
      rpc_set_password
      rpc_start_server
      http_start_server
    )

    def initialize
      @wallet_api = JSON.parse(IO.read(File.dirname(__FILE__) + '/wallet_api.json'))
      @network_api = JSON.parse(IO.read(File.dirname(__FILE__) + '/network_api.json'))
      @blockchain_api = JSON.parse(IO.read(File.dirname(__FILE__) + '/blockchain_api.json'))
      @general_api = JSON.parse(IO.read(File.dirname(__FILE__) + '/general_api.json'))
      @wallet_methods = {}
      @wallet_api['methods'].each {|m| @wallet_methods[m['method_name']] = m['parameters']}
    end

    def sanitize(account_name, method, params)
      return false if RESTRICTED_CALLS.include? method
      if method.start_with? 'wallet_'
        return false if %w(key import backup mail login sign).detect {|w| method.include? w }
        m = @wallet_methods[method]
        return false unless m
        account_name_index = m.find_index {|p| p['name'].include? 'account_name'}
        if account_name_index
          puts "----------- #{method}: #{params[account_name_index]} => #{account_name}"
          params[account_name_index] = account_name
        end
      end
      return true
    end

  end
end

if $0 == __FILE__
  api = BitShares::CallsSanitizer.new

  params = [1,2,3,4,5]
  res = api.sanitize '***', 'wallet_account_transaction_history', params
  puts "sanitize result: #{res}"
  puts params

  api.wallet_api['methods'].each do |m|
    method = m['method_name']
    account_name_index = m['parameters'].find_index {|p| p['name'].include? 'account_name'}
    puts "*account* #{account_name_index} #{method}" if account_name_index

    res = %w(key import backup mail login list sign).detect {|w| method.include? w }
    unless res.nil?
      puts "#{method} keyword restricted : '#{res}'"
    end
    puts "*restricted* #{method}" if BitShares::CallsSanitizer::RESTRICTED_CALLS.include? method
  end
end
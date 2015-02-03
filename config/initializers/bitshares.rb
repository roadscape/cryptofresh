STORE = YAML.load_file('config/store.yml')

require Rails.root.join("lib/BitShares/bitshares_api.rb").to_s
require Rails.root.join("lib/BitShares/calls_sanitizer.rb").to_s

BitShares::API.init(STORE['rpc_port'], STORE['rpc_user'], STORE['rpc_pass'])

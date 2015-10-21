STORE = YAML.load_file('config/store.yml')

require Rails.root.join("lib/graphene_api.rb").to_s
Graphene::API::RPC.init(STORE['rpc_url'])

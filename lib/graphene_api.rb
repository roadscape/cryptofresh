#!/usr/local/rvm/rubies/ruby-2.1.3/bin/ruby

require 'net/http'
require 'uri'
require 'json'

# http://docs.bitshares.eu/api/access.html

module Graphene

  class API
    class RPC
      @@rpc = nil
      
      def self.init(url = 'http://127.0.0.1:8092/rpc', username = nil, password = nil)
        @@rpc ||= Graphene::API::RPC.new(url, username, password)
      end
      def self.instance
        @@rpc || raise("Not initialized!")
      end
      def median_feed_price(asset)
        rate = get_asset(asset)['options']['core_exchange_rate']
        amount(rate['base']) / amount(rate['quote'])
      end

      def initialize(url = 'http://127.0.0.1:8092/rpc', username = nil, password = nil)
        @uri = URI(url)
        @req = Net::HTTP::Post.new(@uri)
        @req.content_type = 'application/json'
        @req.basic_auth username, password if username
      end

      def self.method_missing(name, *params)
        @@rpc.send(name, params)
      end
      def method_missing(name, *params)
        request(name, params)
      end

      def request(method, params)
        response = nil
        body     = {jsonrpc: "2.0", method: method, params: params, id: 0}
        Net::HTTP.start(@uri.hostname, @uri.port) do |http|
          @req.body = body.to_json
          response  = http.request(@req)
        end
        result = JSON.parse(response.body)
        raise RuntimeError, "called #{method}:#{params} -- #{result['error']}" if result['error']
        result['result']
      end

    protected
      def amount(data)
        zeroes = get_asset(data['asset_id'])['precision']
        data['amount'].to_f / 10**zeroes
      end
    end
  end

end


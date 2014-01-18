$:.unshift File.dirname(__FILE__)

# Required gems
require "rubygems"
require "digest/sha2"
require "addressable/uri"
require "faraday"

# Other Requirements
require "vtweb/config"
require "vtweb/merchant_hash_generator"
require "vtweb/post_params"
require "vtweb/version"

module Vtweb
  class Client
      include RbConfig

      def initialize(&block)
        class <<self
          self
        end.class_eval do
          attr_accessor(:item, *PostParams::AllParam) 
        end
      
        self.billing_different_with_shipping = Config::BILLING_DIFFERENT_WITH_SHIPPING 
        self.payment_type                    = Config::PAYMENT_TYPE
      end

      def get_keys
        init_instance
      
        if billing_different_with_shipping == "0" && required_shipping_address == "0"
          raise "required_shipping_address must be '1'"
        end

        params = prepare_params(PostParams::ServerParams,PostParams::AllParam)
        
        # Payment Options
        if !params[:promo_bins].blank?
          params.merge!({ "promo_bins[]" => params[:promo_bins]})
          params.delete :promo_bins
        end

        if !params[:point_banks].blank?
          params.merge!({ "point_banks[]" => params[:point_banks]})
          params.delete :point_banks
        end

        if !params[:installment_banks].blank?
          params.merge!({ "installment_banks[]" => params[:installment_banks]})
          params.delete :installment_banks
        end

        if !params[:installment_terms].blank?
          params.merge!({ "installment_terms" => params[:installment_terms].to_json })
          params.delete :installment_terms
        end
  
        if !params[:payment_methods].blank?
          params.merge!({ "payment_methods[]" => params[:payment_methods]})
          params.delete :payment_methods
        end
      
        # Items
        item = @item.collect do |data|
          data.keys.map do |key|
            if key.downcase == "item_id"
              data["item_id[]"] = data[key]            
            end
          
            if key.downcase == "price"
              data["price[]"] = data[key]
            end

            if key.downcase == "quantity"
              data["quantity[]"] = data[key]
            end

            if key.downcase == "item_name1"
              data["item_name1[]"] = data[key]
            end

            if key.downcase == "item_name2"
              data["item_name2[]"] = data[key]
            end

            data.delete key
          end        

          orders_uri = Addressable::URI.new
          orders_uri.query_values = data
          orders_uri.query
          
        end

        uri = Addressable::URI.new
        uri.query_values = params
        query_string = "#{uri.query}&repeat_line=#{item.length}&#{item.join('&')}"
    
        conn = Faraday.new(:url => vtweb_server)
        @resp = conn.post do |req|
          req.url(Config::GET_TOKENS_URL)
          req.body = query_string
        end.env
      
        delete_keys
        @resp[:url] = @resp[:url].to_s

        @token = parse_body(@resp[:body])
      end

      def server_host
        return Client.config["vtweb_server"] ? Client.config["vtweb_server"] : Config::VTWEB_SERVER
      end

      def redirection_url
        "#{vtweb_server}#{redirection_url}"
      end

      def merchant_id
        return Client.config["merchant_id"]
      end

      def merchant_id= new_merchant_id
        Client.config["merchant_id"] = new_merchant_id
      end

      def merchant_hash_key
        return Client.config["merchant_hash_key"]
      end

      def merchant_hash_key= new_merchant_hash_key
        Client.config["merchant_hash_key"] = new_merchant_hash_key
      end

      def error_payment_return_url
        return Client.config["error_payment_return_url"]
      end

      def finish_payment_return_url
        return Client.config["finish_payment_return_url"]
      end

      def unfinish_payment_return_url
        return Client.config["unfinish_payment_return_url"]
      end

      def token
        return @token
      end

      def billing_different_with_shipping
        @billing_different_with_shipping
      end

      def billing_different_with_shipping=(flag)
        @billing_different_with_shipping = billing_different_with_shipping
      end

      def required_shipping_address
        @required_shipping_address
      end

      def required_shipping_address=(flag)
        @required_shipping_address = flag
      end

      def new_api
        return true
      end

      private

      def merchanthash
        return MerchantHashGenerator::generate(merchant_id, merchant_hash_key, payment_type, order_id);
      end

      def parse_body(body)
        arrs = body.split("\r\n")
        arrs = arrs[-2,2] if arrs.length > 1
        return Hash[arrs.collect{|x|x.split("=")}]
      end
  
      def init_instance
        @token = nil
      end

      def prepare_params(*arg)
        params = {}
        arg.flatten.each do |key|
          value = self.send(key)
          params[key.downcase] = value if value 
        end
        return params
      end

      def delete_keys
        @resp.delete(:ssl)
        @resp.delete(:request)
        @resp.delete(:response)
        @resp.delete(:request_headers)
        @resp.delete(:parallel_manager)
      end
  end
end

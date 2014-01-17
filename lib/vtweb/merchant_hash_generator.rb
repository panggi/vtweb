module Vtweb
  module MerchantHashGenerator
    def self.generate(merchant_id, merchant_hash_key, payment_type, order_id)
      Digest::SHA512.hexdigest("#{merchant_hash_key},#{merchant_id},#{payment_type},#{order_id}")
    end
  end
end
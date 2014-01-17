module Vtweb

  module PostParams

    Merchant =[
      :merchant_id,  
      :merchanthash,
      :finish_payment_return_url,
      :unfinish_payment_return_url,
      :error_payment_return_url
    ]

    Payment =[
      :payment_type, 
      :installment_type,
      :installment_banks,
      :installment_terms,
      :point_banks,
      :payment_methods,
      :promo_bins,
      :enable_3d_secure,
      :bank
    ]

    Personal =[
      :first_name,
      :last_name,
      :address1,
      :address2,
      :city,
      :country_code,
      :postal_code,
      :phone,
      :email,
      :billing_different_with_shipping 
    ]

    Shipping =[
      :required_shipping_address,
      :shipping_first_name,
      :shipping_last_name,
      :shipping_address1,
      :shipping_address2,
      :shipping_city,
      :shipping_country_code,
      :shipping_postal_code,
      :shipping_phone,
      :shipping_email
    ]

    Purchases =[
      :repeat_line
    ]

    OtherParams =[
      :order_id, 
      :new_api
    ]
    
    ServerParams =[
      :merchant_id, 
      :merchanthash,
      :finish_payment_return_url,
      :unfinish_payment_return_url,
      :error_payment_return_url,
      :new_api
    ]

    AllParam = (Merchant + Payment + Personal + Shipping + Language + Purchases + OtherParams) - ServerParams
  end

end
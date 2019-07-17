require 'sinatra'
require "stripe"
require "sinatra/cors"
require 'adyen-ruby-api-library'
require 'byebug'
require 'braintree'
require 'spreedly'

adyen = Adyen::Client.new 
adyen.env = :test
# adyen.api_key = "AQErhmfxL4PIYhRAw0m/n3Q5qf3Va4NMH5RPWmBTCbxqdVh9nev0UTOvnsds3xDBXVsNvuR83LVYjEgiTGAH-6jn1Y74ao7ButC3mVV/nncKdeLWdD4MoDsuumXUPjhA=-E3SJck5grk98mIpv"
adyen.ws_user = 'ws@Company.Chargebee'
adyen.ws_password = 'sKkmvzPgY}T8b-2K3n6n[%F*^'

set :allow_origin, "*"
set :allow_methods, "GET,HEAD,POST"
set :allow_headers, "content-type,if-modified-since"
Stripe.api_key = 'sk_test_TD6l07P6J8pKb6WMwSmWz2nE'

################### Spreedly

  env = Spreedly::Environment.new("B6bJMGhty3Xei2UJ7xIc1QzQHH1", "Mfn8SIp5QjAp48ntS1DtM3MAKwKpTn359Sgxpgptsez3PiDfPUfzLxmwMx3msve2")

  post '/spreedly/authorize' do
  data = JSON.parse(request.body.read.to_s)

begin
  auth = env.authorize_on_gateway("WXd7M0egSDq351BWM9OjH5nrkTT", data["token_id"], 4432, retain_on_success: true, attempt_3dsecure: true, callback_url: "https://www.google.com", redirect_url: "http://www.localhost:9999/spreedly/SpreedlyFinal.html")
return [200, {'Content-Type' => 'application/json'}, {succeeded: auth.succeeded, token: auth.token, checkout_form: auth.checkout_form}.to_json]
end
end

post '/spreedly/capture' do
  data = JSON.parse(request.body.read.to_s)
    trans = env.find_transaction(data["token_id"])
   if(trans.succeeded == true) then
      capture =  env.capture_transaction(data["token_id"])
     return [200, {'Content-Type' => 'application/json'}, {succeeded: capture.succeeded}.to_json]
    end
      return [200, {'Content-Type' => 'application/json'}, {succeeded: false}.to_json]
end

###################

#################### braintreee

Braintree::Configuration.environment = :sandbox
Braintree::Configuration.merchant_id = "jszbnz6jgstn85rp"
Braintree::Configuration.public_key = "x8xhgh2t68zz83fp"
Braintree::Configuration.private_key = "ce975729cbad5bf5ab882a289818668e"

#braintree = Braintree::Gateway.new(
 # :environment => :sandbox,
  #:merchant_id => "jszbnz6jgstn85rp",
  #:public_key => "x8xhgh2t68zz83fp",
  #:private_key => "ce975729cbad5bf5ab882a289818668e"
#)

#################
post '/braintree/nonce' do
  data = JSON.parse(request.body.read.to_s)
 response =  Braintree::PaymentMethodNonce.create(data['card_token'])
   nonce = response.payment_method_nonce.nonce
   puts nonce
return [200, {'Content-Type' => 'application/json', "Access-Control-Allow-Origin" => "*", 
"Access-Control-Allow-Credentials" => "true" }, {temp_token: nonce}.to_json]
end


get '/braintree/client_token' do
 response =  Braintree::ClientToken.generate(
  :merchant_account_id => 'cb-local-test'
 )
return [200, {'Content-Type' => 'application/json'}, response]
end

post '/braintree/sale' do
data = JSON.parse(request.body.read.to_s)
print data['nonce']  
        response = Braintree::Transaction.sale(
              :amount => "12",
              :merchant_account_id => "cb-local-test",
              :payment_method_nonce => data['nonce'],
              :options => {
              :submit_for_settlement => true,
              :store_in_vault => true,
             })
        
      if response.success?
           transaction = response.transaction
           puts "Success Txn_id:"+ transaction.id
           return [200, {'Content-Type' => 'application/json', "Access-Control-Allow-Origin" => "*", 
"Access-Control-Allow-Credentials" => "true" }, {status: 'success', txn_id: transaction.id}.to_json]
      else
      response.errors.each do |error|
       puts error.attribute
       puts error.code
       puts error.message
       end
       return  [200, {'Content-Type' => 'application/json', "Access-Control-Allow-Origin" => "*", 
"Access-Control-Allow-Credentials" => "true" }, {status: 'failure', error: response.message}.to_json]
      end
      
end



get '/adyen/payment_methods' do
  response = adyen.checkout.payment_methods({
    :merchantAccount => 'ChargebeeCOM',
    :countryCode => 'NL',
    :amount => {
      :currency => 'EUR',
      :value => 10000
    },
    :channel => 'Web'
  })
  return [200, {'Content-Type' => 'application/json'}, response.body]
end

post '/adyen/get_origin_key' do
  response = adyen.checkout_utility.origin_keys({
    :originDomains => ["http://localhost:9000"]
  })
  return [200, {'Content-Type' => 'application/json'}, response.body]
end

post '/adyen/webhook' do
    data = JSON.parse(request.body.read.to_s)
    puts data
   end 

post '/adyen/authrize' do
   response = adyen.checkout.payments({
    :merchantAccount => 'ChargebeeCOM',
    :additionalData => {
      "allow3DS2" => true
    },
    # "accountInfo": {
    #   "accountCreationDate": "2019-01-17T13:42:40+01:00"
    # },
    "browserInfo":{     
      "userAgent":"Mozilla\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\/537.36 (KHTML, like Gecko) Chrome\/70.0.3538.110 Safari\/537.36",
      "acceptHeader":"text\/html,application\/xhtml+xml,application\/xml;q=0.9,image\/webp,image\/apng,*\/*;q=0.8",
      "language":"nl-NL",
      "colorDepth":24,
      "screenHeight":723,
      "screenWidth":1536,
      "timeZoneOffset":0,
      "javaEnabled": true
    },
    "billingAddress": {
      "country": "US",
      "street": "Haarlem",
      "city": "New York",
      "houseNumberOrName": "37",
      "stateOrProvince": "CA",
      "postalCode": "10BA"
    },
    "origin": "https://your-company.com/",
    :channel => 'Web',
    # :countryCode => 'NL',
    :reference => "test",
    :paymentMethod => {
       :type => "scheme",
       :number => "4212345678901245",
       :expiryMonth => "08",
        :expiryYear => "2018",
        :cvc => "737"
      },
     :threeDSAuthenticationOnly => true,
    :amount => {
      :currency => 'EUR',
      :value => 10000
    },
    :returnUrl => "https://your-company.com/checkout/"
  })
    return [200, {'Content-Type' => 'application/json'}, response.body]
  end

  post '/adyen/payment_details' do
       data = JSON.parse(request.body.read.to_s)
       puts data
         adyen.instance_variable_set("@version", 49);
         checkout = adyen.checkout
         checkout.instance_variable_set("@version", 49)
        response = checkout.payments.details({
          :details => data['details'],
          :paymentData => data['paymentData'],
          :threeDSAuthenticationOnly => false
           })
      puts "=================================================="  
      puts response.body  
  return [200, {'Content-Type' => 'application/json'}, response.body]
end




post '/adyen/payments' do
  data = JSON.parse(request.body.read.to_s)
  adyen.instance_variable_set("@version", 49);
  # response = adyen.checkout.payments({
  #   "amount": {
  #     "currency": "USD",
  #     "value": 1000
  #   },
  #   "reference": "YOUR_ORDER_NUMBER",
  #   "paymentMethod": data['paymentMethod'],
  #   "additionalData": {
  #     "allow3DS2": true
  #   },
  #   "accountInfo": {
  #     "accountCreationDate": "2019-01-17T13:42:40+01:00"
  #   },
  #   "billingAddress": {
  #     "country": "US",
  #     "street": "Haarlem",
  #     "city": "New York",
  #     "houseNumberOrName": "37",
  #     "stateOrProvince": "CA",
  #     "postalCode": "10BA"
  #   },
  #   "shopperEmail": "s.hopper@test.com",
  #   "browserInfo": {
  #     "userAgent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.110 Safari/537.36",
  #     "acceptHeader": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8",
  #     "language": "nl-NL",
  #     "colorDepth": 24,
  #     "screenHeight": 723,
  #     "screenWidth": 1536,
  #     "timeZoneOffset": 0,
  #     "javaEnabled": true
  #   },
  #   "channel": "web",
  #   "origin": "https://your-company.com/",
  #   "returnUrl": "https://your-company.com/checkout/",
  #   "merchantAccount": "ChargebeeCOM"
  # })
  checkout = adyen.checkout
  checkout.instance_variable_set("@version", 49)
  response = checkout.payments({
    :merchantAccount => 'ChargebeeCOM',
    :additionalData => {
      "allow3DS2" => true
    },
    # "accountInfo": {
    #   "accountCreationDate": "2019-01-17T13:42:40+01:00"
    # },
    "browserInfo":{     
      "userAgent":"Mozilla\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\/537.36 (KHTML, like Gecko) Chrome\/70.0.3538.110 Safari\/537.36",
      "acceptHeader":"text\/html,application\/xhtml+xml,application\/xml;q=0.9,image\/webp,image\/apng,*\/*;q=0.8",
      "language":"nl-NL",
      "colorDepth":24,
      "screenHeight":723,
      "screenWidth":1536,
      "timeZoneOffset":0,
      "javaEnabled": true
    },
    "billingAddress": {
      "country": "US",
      "street": "Haarlem",
      "city": "New York",
      "houseNumberOrName": "37",
      "stateOrProvince": "CA",
      "postalCode": "10BA"
    },
    "origin": "http://localhost:9999",
    :channel => 'Web',
    # :countryCode => 'NL',
    :authenticationOnly => true,
    :reference => "test",
    :paymentMethod => data['paymentMethod'],
    :amount => {
      :currency => 'EUR',
      :value => 10000
    },
    :returnUrl => "https://your-company.com/checkout/"
  })
  return [200, {'Content-Type' => 'application/json', "Access-Control-Allow-Origin" => "*", 
"Access-Control-Allow-Credentials" => "true" }, response.body]
end


post '/ajax/confirm_payment_using_temptoken' do
  data = JSON.parse(request.body.read.to_s)
  begin
    intent = Stripe::PaymentIntent.create({
      payment_method_data: {
          type: 'card',
          card: {token: data['token_id']},
      },
      amount: 1099,
      customer: data['customer_id'],
      currency: 'usd',
      confirmation_method: 'manual',
      confirm: true,
    })
  rescue Stripe::CardError => e
    # Display error on client
    return [200, {'Content-Type' => 'application/json'}, { error: e.message }.to_json]
  end

  return generate_payment_response(intent)
end

post '/ajax/confirm_payment' do
  data = JSON.parse(request.body.read.to_s)
  begin
    if data['payment_method_id']
      # Create the PaymentIntent
      intent = Stripe::PaymentIntent.create(
        payment_method: data['payment_method_id'],
        amount: 1099,
        currency: 'usd',
        confirmation_method: 'manual',
        confirm: true,
      )
    elsif data['payment_intent_id']
      intent = Stripe::PaymentIntent.confirm(data['payment_intent_id'])
    end
  rescue Stripe::CardError => e
    # Display error on client
    return [200, { error: e.message }.to_json]
  end

  return generate_payment_response(intent)
end

def generate_payment_response(intent)
  if (intent.status == 'requires_source_action' || intent.status == 'requires_action') &&
      intent.next_action.type == 'use_stripe_sdk'
    # Tell the client to handle the action
    [
      200,
      {
        requires_action: true,
        payment_intent_client_secret: intent.client_secret
      }.to_json
    ]
  elsif intent.status == 'succeeded'
    # The payment didn’t need any additional actions and completed!
    # Handle post-payment fulfillment
    [200, { success: true, payment_intent_id: intent.id }.to_json]
  else
    # Invalid status
    return [500, { error: intent.status }.to_json]
  end
end

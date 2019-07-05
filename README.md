
- Go to server folder

   Run - $ bundle install

   Start server - $ ruby app.rb // localhost:4567

- For Braintree

    - Go to braintree folder

    - Start server: $ python -m SimpleHTTPServer 9999

    - For new card use: http://localhost:9999/new_card.html
    
    - For existing card use: http://localhost:9999/existing_card.html
    
- For Adyen
     - Go to adyen folder
     
     - Start server: $ python -m SimpleHTTPServer 9999

     - For new card use: http://localhost:9999/adyen1.html
    
     - To listen webook , start ngrok on port-4567 configure the url: nogrok/adyen/webhook

- For Stripe
    - Go to stripe folder

    - start server: $ python -m SimpleHTTPServer 9999

- For Spreedly
    - Go to spreedly folder

    - Start server: $ python -m SimpleHTTPServer 9999

    - open www.localhost:9999/spreedly/spreedly.html
    - provide the test card number as "4556761029983886" for 3ds testing


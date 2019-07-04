
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

    - to make it work for spreedly we need to setup local dns

    DNS setup: click on apple icon on top left corner and choose system preference -> network: then u should see your ip address , make a note of ip address and type "$sudo subl /etc/hosts". command
    - then add your ip address and dns name as www.localtest.com
    example:  ##
        # Host Database
        #
        # localhost is used to configure the loopback interface
        # when the system is booting.  Do not change this entry.
        ##
        127.0.0.1   localhost
        192.168.1.6 www.localtest.com
        255.255.255.255 broadcasthost
        ::1             localhost

        #############

    - open www.localtest.com:9999/spreedly/spreedly.html
    - provide the test card number as "4556761029983886" for 3ds testing


# assignment-jan-we
## Auction house systeem

auction_application is our backend, in our backend we have an Auction System and User system, this communicates with a pub/sub rabbitmq channel to our frontend (frontend_auction/auction_frontend). With our auction house system you can make an auction by giving it a title, seller, price & a boolean telling if the auction is ended or not yet started. When you want to place a bid you will only need to give the title of the auction you want to place a bid on. Doing so will increase the price with 10. It is possible to end an auction by only giving the title of the auction you want to end, doing so the auction will be marked as an ended auction and when you want to bid on this auction after doing so, you will get a message saying it's no longer possible to bid on the giving auction because of it being ended. The price of the ended auction will also not increase when trying this. Requesting all auctions will result in an extra log message with all auctions as the result. 

It is also possible to create a user when giving a username and password. You can view all the users and they will be shown in the logs as the result.

* Our frontend is an API where we can: 

  **- api/create/titel/seller/price/ended**
  -> via auction exchange om een auction toe te voegen
    Titel = de titel van de auction
    Seller = verkoper van de auction
    price = prijs van de auction
    ended = a boolean that shows if the auction is over or not
    
  **- api/bid/titel**
  -> via auction exchange om te bieden op een bepaalde auction
    Titel = de titel van de auction
    note: deze gaat ook na of de auction nog lopende is of niet. zo niet krijg je het resultaat: "auction ended" in de logs te zien
    
  **- api/end/title**
  -> via auction exchange om een bepaalde auction te laten stoppen
    Titel = de titel van de auction
  
   **- api/auctions**
  -> via auction exchange
    -> shows sends a request for a list of all auctions 
      -> api/logs/full will show the list next to the used commando
      
  **- api/create_user/username/password**
  -> via user exchange
    username = de naam van het account dat je wilt maken
    password = het wachtwoord voor je account 
  
   **- api/users**
  -> via user exchange
    -> shows sends a request for a list of all users 
      -> api/logs/full will show the list next to the used commando
 
   
  (Update price (would be when someone places a bid on the auction, each bid in our auction api goes up by 10 but only when the auction is not ended))

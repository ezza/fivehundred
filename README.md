###  Fivehundred

Play 500 with 1-4 players and optional AIs. Quite rough around the edges.

http://fivehundreds.herokuapp.com/

###  TODO
- Validations so it is not possible to reneg
- Move the bidding and playing AIs out of the hand model
- AI bids over its partner when it doesn't need to to win the trick
- AI leads trumps after it knows only it and it's partner have trumps left
- Websockets!
- Running specs currently requires db seeds to be loaded in test env
- show each bid even if the player passes
- show what was in kitty afterwards
- if you're trumping, make sure you trump higher than any existing trumps

### Development
## Server
- bundle install
- rake db:create
- rake db:migrate
- rake db:seed
- rails s

## Additionally for tests
- rake db:test:prepare
- RAILS_ENV=test rake db:seed
- rake spec

# Metgauge

## Prereq

- Erlang 25.0.3 (via [asdf](https://github.com/asdf-vm/asdf))
- Elixir  1.13.4-otp-25 (via [asdf](https://github.com/asdf-vm/asdf))
- Nodejs 16.16.0 (via [asdf](https://github.com/asdf-vm/asdf))
- PostgreSQL 14.4
- When using Google Chrome, open `chrome://flags/#allow-insecure-localhost` to `enable` the use of self-signed certificates on `localhost`.
- Facebook login on localhost need to get Meta Developer privilege from `Eric` or `Mickey`.


## Getting Started

To start your Phoenix server:

- Install dependencies with `mix deps.get`
- Install Node.js dependencies with `npm install --prefix assets`
- Deploy assets with `cd assets; npm run deploy; cd ..`
- Create and migrate your database with `mix ecto.setup`
- Start Phoenix endpoint with either `mix phx.server` or in interactive mode with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check the deployment section](#deploying).

apt-get install imagemagick
cd /home/kiril/metgauge
git fetch origin && git reset --hard origin/master
source .env
MIX_ENV=prod mix deps.get
MIX_ENV=prod mix compile --force
MIX_ENV=prod mix ecto.migrate
MIX_ENV=prod mix tailwind default
cd assets
node build.js --deploy
npm install run
npm run deploy
cd ..
MIX_ENV=prod mix tailwind default
MIX_ENV=prod mix phx.digest
MIX_ENV=prod mix release
sudo systemctl restart mover

ln -s /home/kiril/metgauge/uploads /home/kiril/metgauge/priv/static/uploads
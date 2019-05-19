# mprop-crystal

A `Crystal::LiveView` port of [Mitchell Henke's `Phoenix.LiveView` Milwaukee Property Search app](https://mobile.twitter.com/MitchellHenke/status/1121803306081320963).

## Installation

    git clone https://github.com/jgaskins/mprop-crystal.git
    cd mprop-crystal
    shards
    createdb mprop

## Usage

First we need to download the data from the Millwaukee city website

    curl https://itmdapps.milwaukee.gov/xmldata/Get_mprop_csv -o mprop.csv

Then we load it into the database. We'll need the DB URL so we'll export it to our shell environment here

_Note: This takes quite a while to load_

    export DATABASE_URL=postgres://localhost/mprop
    crystal seed_db.cr mprop.csv

Then we run the app. By default it listens on port 9393, but you can change it with the `PORT` shell environment variable.

    crystal src/mprop.cr

## Development

    ¯\_(ツ)_/¯

## Contributing

1. Fork it (<https://github.com/jgaskins/mprop-crystal/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Jamie Gaskins](https://github.com/jgaskins) - creator and maintainer

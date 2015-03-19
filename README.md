# Nebulous

[![Build Status](https://travis-ci.org/zachgraves/nebulous.svg)](https://travis-ci.org/zachgraves/nebulous.svg)

Easily read CSV files. Less murderous rage.

## Installation

Add this line to your application's Gemfile:

    gem 'nebulous'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install nebulous

## Usage

Nebulous is a bit easier going than other CSV libraries for Ruby. It will parse
data that would otherwise fail with Ruby's CSV and supports the common problems
that are present in real-world CSV files. Nebulous will also try to intelligently
determine the column delimiters and line terminators before parsing so you don't
have to. Which makes handling CSV file uploads a breeze when you have no idea
what you might get. Let's cover some examples.

    Nebulous.process "path/to/file.csv"
    => [{:first_name=>"Meghan", :last_name=>"Koch"},
        {:first_name=>"Genoveva", :last_name=>"Dare"}, ...]

Or process within a block in chunks of 10

    Nebulous.process "path/to/file.csv", chunk: 10 do |chunk|
      p chunk
    end
    => [{:first_name=>"Meghan", :last_name=>"Koch"},
        {:first_name=>"Genoveva", :last_name=>"Dare"}, ...]
    => [{:first_name=>"Chad", :last_name=>"Anderson"},
        {:first_name=>"Arnold", :last_name=>"Yundt"}, ...]


Or provide your own header mapping to normalize columns:

    map = {first_name: :col1, last_name: :col2 }
    Nebulous.process "path/to/file.csv", mapping: map
    => [{:col1=>"どーもありがとう", :col2=>"ミスター·ロボット"},
        {:col1=>"Meghan", :col2=>"Koch"}, 
        {:col1=>"Genoveva", :col2=>"Dare"}]


If you know your CSV file does not contain headers it will return simple Arrays.

    Nebulous.process "path/to/file.csv", headers: false
    => [["どーもありがとう", "ミスター·ロボット"],
        ["Meghan", "Koch"], 
        ["Genoveva", "Dare"]]

Or provide a limit:

    Nebulous.process "path/to/file.csv", limit: 1
    => [{:first_name=>"どーもありがとう", :last_name=>"ミスター·ロボット"}]


## Contributing

1. Fork it ( https://github.com/zachgraves/nebulous/fork )
2. Create your feature branch (`git checkout -b feature/my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin feature/my-new-feature`)
5. Create a new Pull Request targetting `develop`

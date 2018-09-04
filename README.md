# RailsEdgeTest

There is a particular type of integration testing that we have found very fruitful. We:
- load up our front-end with its virtual dom, 
- assert expectations by querying the virtual dom, and 
- interact with our application by simulating events on elements in the virtual dom

We have found these browser-less integration tests to be orders of magnitude faster than typical capybara integration tests, with minimal downsides. One of the biggest drawbacks to this approach is that we must maintain the json we expect from the backend in a form that is available to these tests, typically a json file (or Elm file with a json blob). Maintaining the blob causes two problems:
1. The blob can easily become out-of-sync with our backend, and 
2. There is no specification for how to recreate it when things do become out-of-sync.

This gem aims to solve these problems. The rails_edge_test gem allows us to:
- use Ruby code to explicitly specify each json blob our front-end tests require, 
- re-generate these files, as needed, with a simple rake task.

We write what we call "edge specs," Ruby files that specify the json edge between our front- and back-end by using our Rails models and controller actions directly. These are written using a DSL evocative of an RSpec spec. They allow us to generate json blob files which we commit to our repo, and access from our front-end integration tests. Over time, as our APIs develop, we can simply rerun our edge specs in order to update these json blobs based on existing specifications.


## Installation

Add this line to your application's Gemfile, and make sure it's available to your test environment:

```ruby
gem 'rails_edge_test'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rails_edge_test

## Usage

For example:

```ruby
# spec/edge/rails_controller_edge.rb

include RailsEdgeTest::Dsl

controller HomeController do
  action :show do
    let(:user) { create :user }
    
    edge "first time user" do
      user
      perform_get
      
      # generates Edge.HomeController.Show.FirstTimeUser with `json` function
      produce_elm_file('FirstTimeUser') 
    end
    
    edge "returning user" do
      user
      create :post, user: user
      perform_get
      
      # generates Edge.HomeController.Show.ReturningUser with `json` function
      produce_elm_file('ReturningUser') 
    end
  end
end
```

Edge specifications, like the above, should be put in subfolders of `/edge` and must be named `*_edge.rb`.

## Generating files

When you want to generate your edge json files, run this:

`bundle exec generate_edges`

You can also pass in a file path relative to the edge root path (usually spec/edge):
`bundle exec generate_edges rails_controller_edge.rb`

## Some helpful setup

You may want to use some or all of this setup:

```ruby
# config/initializers/rails_edge_test.rb

if defined?(RailsEdgeTest)
  RailsEdgeTest.configure do |config|
    config.edge_root_path = Rails.root.join('edge', 'spec')
    config.elm_path = Rails.root.join('ui', 'tests')
    config.include(FactoryGirl::Syntax::Methods)

    config.before_suite { DatabaseCleaner.strategy = :transaction }
    config.before_each { DatabaseCleaner.start }
    config.after_each { DatabaseCleaner.clean }

    config.printer = RailsEdgeTest::Printers::Tree
  end
end
```

```ruby
# edge/edge_helper.rb

include RailsEdgeTest::Dsl

Dir[Rails.root.join('spec', 'support', '**', '*.rb')].each {|f| require f}
```

```ruby
# edge/<the name of your file>_edge.rb

require Rails.root.join('edge', 'spec', 'edge_helper')

#...
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

To release a new version, follow the instructions in [PUBLISHING.md](PUBLISHING.md).


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/NoRedInk/rails_edge_test. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).


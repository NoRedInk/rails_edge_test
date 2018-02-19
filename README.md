# RailsEdgeTest

Do you have front-end tests that require large json blobs? Do you use Rails for your backend? Then, you can use this gem to have Rails generate your json blobs programmatically!

Use the rails_edge_test DSL (modeled after RSpec) to define your json files.


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
# edge/rails_controller_edge.rb

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

When you want to generate your edge json files, run this rake task:

`RAILS_ENV=test rake rails_edge_test:generate_files`

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

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/NoRedInk/rails_edge_test. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).


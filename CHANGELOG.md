# The Changelog

## Version 3.0.0: Unreleased
- drops support for ruby < 3.1, rails < 7
- adds support for ruby 3.2, rails 7.2

## Version 2.1.0: August 13, 2024
- adds `delete` method for simulating delete requests
- adds `set_authenticity_token` method for setting the authenticity token in the header & session

## Version 2.0.0: August 13, 2024
- drops support for Ruby 2.*
- adds `post` method for simulating post requests

## Version 1.2.3: December 8, 2020
- Add rails 6 support (#39)

## Version 1.2.2: April 20, 2020
- config.include allows module functions to be available within controller helper methods

## Version 1.2.1: April 17, 2020

- fix delegate method not being defined

## Version 1.2.0: April 17, 2020

- nix developer setup (#28, thanks @arkham!)
- support scoped defined methods (with `def`) (#29, thanks @arkham!)

## Version 1.1.1: January 17, 2019

- test fixes (#25)
- more deterministic edge generation (#26)

## Version 1.1.0: April 2, 2019

- Edges passed in on command line must have the whole path. We _only_ look for edges by default in the `edge_root_path`, not also in the root path.

## Version 1.0.0: Feb 15, 2019

- Deprecate Rails 4, add support for Rails 5

## Version 0.8.0: April 2, 2019

- Edges passed in on command line must have the whole path. We _only_ look for edges by default in the `edge_root_path`, not also in the root path.

## Version 0.7.0: Dec 5, 2018

- We can now pass a real path to the generate_edges command

## Version 0.6.0: Sep 4, 2018

- Bug fixes for generated JSON is now formatted to aid in comparing versions of generated fixtures

## Version 0.5.0: Sep 4, 2018

- Generated JSON is now formatted to aid in comparing versions of generated fixtures

## Version 0.4.0: Aug 16, 2018

- `let` bindings can now be set at the controller level and overridden or used in child actions.

## Version 0.3.0: Mar 7, 2018

- User can generate edges, one file at a time, by passing filename into new exe/generate_edges

    ```sh
    bundle exec generate_edges path/to/my_edge.rb
    ```

- Replaced rake task with RailsEdgeTest::Runner

## Version 0.2.2: Feb 20, 2018

- Beginning of this changelog.

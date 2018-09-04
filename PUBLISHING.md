# How to publish a new release

You will need:

- A rubygems.org account that has been added to the rails_edge_test gem.

How to release:

- Update `CHANGELOG.md`
- Update the version number in:
    - `lib/rails_edge_test/version.rb`
    - `spec/support/test_app/Gemfile.lock`
- Ensure tests pass `bundle exec rake spec`
- Commit your changes
- Run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

You can see the published gem at <https://rubygems.org/gems/rails_edge_test>

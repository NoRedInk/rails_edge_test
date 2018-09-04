# How to publish a new release

- Update `CHANGELOG.md`
- Update the version number in `lib/rails_edge_test/version.rb`
- Ensure tests pass `bundle exec rake spec`
- Commit your changes
- Run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

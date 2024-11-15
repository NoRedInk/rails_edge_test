# frozen_string_literal: true

include RailsEdgeTest::Dsl # rubocop:disable Style/MixinUsage

controller ApplicationController do
  action :home do
    edge 'write elm file' do
      perform_get
      produce_elm_file('Another')
    end
  end
end

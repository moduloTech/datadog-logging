# frozen_string_literal: true

RSpec.describe Datadog::Logging do
  it "has a version number" do
    expect(Datadog::Logging::VERSION).not_to be nil
  end
end

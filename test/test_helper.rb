ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "minitest/autorun"
require "minitest/reporters"
require "mocha/minitest"

# Configure Minitest reporters for better output
Minitest::Reporters.use! [ Minitest::Reporters::DefaultReporter.new(color: true) ]

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml
  fixtures :all
end

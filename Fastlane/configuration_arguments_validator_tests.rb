# Run test
# bundle exec minitest Fastlane/configuration_arguments_validator_tests.rb

require 'minitest/autorun'
require_relative 'configuration_arguments_validator'

class ConfigurationArgumentsValidatorTests < Minitest::Spec
  describe ConfigurationArgumentsValidator do
    describe '.run' do
      it 'raises ConfigArgumentsMissingError when a value is nil' do
        args = { key1: nil, key2: 'value2' }

        error = assert_raises(ConfigurationArgumentsValidator::ConfigArgumentsMissingError) do
          ConfigurationArgumentsValidator.run(args)
        end

        assert_match(/Missing key values: {key1: nil}/, error.message)
      end

      it 'raises ConfigArgumentsMissingError when values are empty' do
        args = { key1: '', key2: [], key3: {}, key4: 'value2' }

        error = assert_raises(ConfigurationArgumentsValidator::ConfigArgumentsMissingError) do
          ConfigurationArgumentsValidator.run(args)
        end

        assert_match(/Missing key values: {key1: \"\", key2: \[\], key3: \{\}}/, error.message)
      end

      it 'does not raise an error when all values are present' do
        args = { key1: 'value1', key2: 'value2' }

        assert_nil ConfigurationArgumentsValidator.run(args)
      end
    end
  end
end

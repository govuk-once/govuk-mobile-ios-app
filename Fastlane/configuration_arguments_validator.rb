# Run test
# bundle exec minitest Fastlane/configuration_arguments_validator_tests.rb

class ConfigurationArgumentsValidator
  def self.run(args)
    errors = args.each_with_object({}) do |(key, value), hsh|
      if empty?(value)
        hsh[key] = value
      end
    end

    unless errors.empty?
      raise ConfigArgumentsMissingError, "Missing key values: #{errors}"
    end
  end

  def self.empty?(obj)
    obj.nil? ? true : obj.empty?
  end

  class ConfigArgumentsMissingError < StandardError; end
end

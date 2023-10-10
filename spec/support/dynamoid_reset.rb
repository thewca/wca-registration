# frozen_string_literal: true

raise "Tests should be run in 'test' environment only" if Rails.env != 'test'

# This is required so that the first test that is run doesn't fail due to table not being created yet - https://github.com/Dynamoid/dynamoid/issues/277
Dir[File.join(Dynamoid::Config.models_dir, '**/*.rb')].each { |file| require file }

module DynamoidReset
  def self.all
    Dynamoid.adapter.list_tables.each do |table|
      # Only delete tables in our namespace
      if table =~ /^#{Dynamoid::Config.namespace}/
        Dynamoid.adapter.delete_table(table)
      end
    end
    Dynamoid.adapter.tables.clear
    # Recreate all tables to avoid unexpected errors
    Dynamoid.included_models.each { |m| m.create_table(sync: true) }
  end
end

# Reduce noise in test output
Dynamoid.logger.level = Logger::FATAL

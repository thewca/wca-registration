# frozen_string_literal: true

raise "Tests should be run in 'test' environment only" if Rails.env != 'test' && Rails.env != 'development'

module DynamoidReset
  def self.all
    puts "DYNAMOID RESETTING!"
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

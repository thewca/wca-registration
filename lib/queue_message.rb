# frozen_string_literal: true

class QueueMessage
  def self.generate_register_message(step_data)
    # We have to manually generate the message because we want to set
    # a specific message deduplication id (as per https://github.com/ruby-shoryuken/shoryuken/wiki/FIFO-Queues)
    # Message payload as per (https://github.com/ruby-shoryuken/shoryuken/wiki/Sending-a-message)
    job_args = {
      job_class: 'RegistrationProcessor',
      job_id: SecureRandom.uuid,
      provider_job_id: nil,
      queue_name: EnvConfig.QUEUE_NAME,
      priority: nil,
      arguments: [
        step_data.merge(aj_symbol_keys: step_data.keys),
      ],
      executions: 0,
      locale: 'en',
    }

    {
      message_body: job_args,
      message_attributes: {
        shoryuken_class: {
          string_value: 'ActiveJob::QueueAdapters::ShoryukenAdapter::JobWrapper',
          data_type: 'String',
        },
      },
      message_group_id: step_data[:competition_id],
      message_deduplication_id: "#{step_data[:step]}-#{step_data[:attendee_id]}",
    }
  end
end

# config/initializers/aws.rb

if Rails.env.production?
  $dynamodb = Aws::DynamoDB::Client.new
  $sqs = Aws::SQS::Client.new
  $queue = ENV["QUEUE_URL"]
else
  # We are using localstack to emulate AWS in dev
  $dynamodb = Aws::DynamoDB::Client.new(endpoint: ENV['LOCALSTACK_ENDPOINT'])
  $sqs = Aws::SQS::Client.new(endpoint: ENV['LOCALSTACK_ENDPOINT'])
end

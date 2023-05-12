# config/initializers/aws.rb

if Rails.env.production?
  # We are using IAM Roles to authenticate in prod
  Aws.config.update({
    region: ENV["AWS_REGION"],
  })
  $dynamodb = Aws::DynamoDB::Client.new
  $sqs = Aws::SQS::Client.new
  $queue = ENV["QUEUE_URL"]
else
  # We are using fake values in dev
  Aws.config.update({
      region: "us-east-1",
      credentials: Aws::Credentials.new('my_cool_key', 'my_cool_secret')
    })

  $dynamodb = Aws::DynamoDB::Client.new(endpoint: ENV['LOCALSTACK_ENDPOINT'])
  $sqs = Aws::SQS::Client.new(endpoint: ENV['LOCALSTACK_ENDPOINT'])
end

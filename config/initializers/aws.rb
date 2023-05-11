# config/initializers/aws.rb

if Rails.env.production?
  # We are using IAM Roles to authenticate in prod
  Aws.config.update({
    region: ENV["AWS_REGION"],
  })
  $dynamodb = Aws::DynamoDB::Client.new
else
  # We are using fake values in dev
  $dynamodb = Aws::DynamoDB::Client.new(endpoint: ENV['DYNAMODB_ENDPOINT'], region: "my-cool-region-1", credentials: Aws::Credentials.new('my_cool_key', 'my_cool_secret'))
end



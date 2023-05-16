# Define the SQS FIFO queue
resource "aws_sqs_queue" "this" {
  name                      = "registrations.fifo"
  fifo_queue                = true
  content_based_deduplication = true
  deduplication_scope        = "queue"
  delay_seconds              = 0
  max_message_size           = 262144
  message_retention_seconds  = 345600 #TODO What are good values for this?
  receive_wait_time_seconds  = 1 # The time the queue waits until it sends messages when polling to better batch message
  visibility_timeout_seconds = 60 # The time until the message is set to be available again to be picked up by another worker
  # because the initial worker might have died
}

output "queue" {
  value = aws_sqs_queue.this
}

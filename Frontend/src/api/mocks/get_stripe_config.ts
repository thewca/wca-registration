import { StripeConfig } from '../payment/get/get_stripe_config'

export default function getStripeConfigMock(): StripeConfig {
  return {
    stripe_publishable_key: 'pk_test_N0KdZIOedIrP8C4bD5XLUxOY',
    connected_account_id: 'acct_1NYpaMGZClrCFkEy',
  }
}

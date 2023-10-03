import { PaymentInfo } from '../registration/get/get_payment_intent'
import getStripeConfigMock from './get_stripe_config'

export default async function getPaymentIntentMock(): Promise<PaymentInfo> {
  const stripeConfig = getStripeConfigMock()

  // Get a Payment Intent from Stripe
  const stripe = require('stripe')('sk_test_CY2eQJchZKUrPGQtJ3Z60ycA')

  const paymentIntent = await stripe.paymentIntents.create(
    {
      amount: 2000,
      currency: 'eur',
      automatic_payment_methods: { enabled: true },
    },
    { stripeAccount: stripeConfig.connected_account_id }
  )
  return {
    client_secret_id: paymentIntent.client_secret,
  }
}

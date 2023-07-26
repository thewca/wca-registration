import { PaymentElement, useElements, useStripe } from '@stripe/react-stripe-js'
import React, { useContext, useState } from 'react'
import { CompetitionContext } from '../../../api/helper/context/competition_context'
import { setMessage } from '../../../ui/events/messages'

export default function PaymentStep() {
  const stripe = useStripe()
  const elements = useElements()
  const [isLoading, setIsLoading] = useState(false)
  const { competitionInfo } = useContext(CompetitionContext)
  const handleSubmit = async (e) => {
    e.preventDefault()

    if (!stripe || !elements) {
      // Stripe.js has not yet loaded.
      // Make sure to disable form submission until Stripe.js has loaded.
      return
    }

    setIsLoading(true)

    const { error } = await stripe.confirmPayment({
      elements,
      confirmParams: {
        // Just for testing, the actual route will probably live somewhere else
        return_url: `${window.location.origin}/api/v10/internal/payment/finish?competition_id=${competitionInfo.id}`,
      },
    })

    // This point will only be reached if there is an immediate error when
    // confirming the payment. Otherwise, your customer will be redirected to
    // your `return_url`. For some payment methods like iDEAL, your customer will
    // be redirected to an intermediate site first to authorize the payment, then
    // redirected to the `return_url`.
    if (error.type === 'card_error' || error.type === 'validation_error') {
      setMessage(error.message, 'error')
    } else {
      setMessage('An unexpected error occured.', 'error')
    }

    setIsLoading(false)
  }

  return (
    <form id="payment-form" onSubmit={handleSubmit}>
      <PaymentElement id="payment-element" />
      <button disabled={isLoading || !stripe || !elements} id="submit">
        <span id="button-text">
          {isLoading ? <div className="spinner" id="spinner" /> : 'Pay now'}
        </span>
      </button>
    </form>
  )
}

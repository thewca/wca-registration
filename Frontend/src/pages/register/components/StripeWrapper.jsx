// Following https://github.com/stripe-samples/accept-a-payment/blob/main/payment-element/client/react-cra/src/Payment.js
import { Elements } from '@stripe/react-stripe-js'
import { loadStripe } from '@stripe/stripe-js'
import { useQuery } from '@tanstack/react-query'
import React, { useContext, useEffect, useState } from 'react'
import { CompetitionContext } from '../../../api/helper/context/competition_context'
import getPaymentClientSecret from '../../../api/registration/get/get_payment_client_secret'
import PaymentPanel from './PaymentPanel'

export default function StripeWrapper() {
  const [stripePromise, setStripePromise] = useState(null)
  const { competitionInfo } = useContext(CompetitionContext)
  const { data, isLoading } = useQuery({
    queryKey: ['payment-secret', competitionInfo.id],
    queryFn: () => getPaymentClientSecret(competitionInfo.id),
    refetchOnWindowFocus: false,
    refetchOnReconnect: false,
    staleTime: Infinity,
    refetchOnMount: 'always',
  })

  useEffect(() => {
    setStripePromise(loadStripe(process.env.STRIPE_PUBLISHABLE_KEY))
  }, [])

  return (
    <>
      <h1>Payment</h1>
      {isLoading && stripePromise && (
        <Elements
          stripe={stripePromise}
          options={{ clientSecret: data.client_secret }}
        >
          <PaymentPanel />
        </Elements>
      )}
    </>
  )
}

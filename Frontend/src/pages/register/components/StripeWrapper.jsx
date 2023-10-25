// Following https://github.com/stripe-samples/accept-a-payment/blob/main/payment-element/client/react-cra/src/Payment.js
import { Elements } from '@stripe/react-stripe-js'
import { loadStripe } from '@stripe/stripe-js'
import { useQuery } from '@tanstack/react-query'
import React, { useContext, useEffect, useState } from 'react'
import { CompetitionContext } from '../../../api/helper/context/competition_context'
import { PAYMENT_NOT_READY } from '../../../api/helper/error_codes'
import getStripeConfig from '../../../api/payment/get/get_stripe_config'
import getPaymentId from '../../../api/registration/get/get_payment_intent'
import { setMessage } from '../../../ui/events/messages'
import PaymentStep from './PaymentStep'

export default function StripeWrapper() {
  const [stripePromise, setStripePromise] = useState(null)
  const { competitionInfo } = useContext(CompetitionContext)
  const {
    data: paymentInfo,
    isLoading: isPaymentIdLoading,
    isError,
  } = useQuery({
    queryKey: ['payment-secret', competitionInfo.id],
    queryFn: () => getPaymentId(competitionInfo.id),
    refetchOnWindowFocus: false,
    refetchOnReconnect: false,
    staleTime: Infinity,
    refetchOnMount: 'always',
    onError: (err) => {
      if (err.error === PAYMENT_NOT_READY) {
        setMessage(
          'You need to finish your registration before you can pay',
          'error'
        )
      } else {
        setMessage(err.error, 'error')
      }
    },
  })

  const { data: config, isLoading: isConfigLoading } = useQuery({
    queryKey: ['payment-config', competitionInfo.id, paymentInfo?.id],
    queryFn: () => getStripeConfig(competitionInfo.id, paymentInfo?.id),
    onError: (err) => setMessage(err.error, 'error'),
    enabled: !isPaymentIdLoading && !isError,
    refetchOnWindowFocus: false,
    refetchOnReconnect: false,
    staleTime: Infinity,
    refetchOnMount: 'always',
  })

  useEffect(() => {
    if (!isConfigLoading) {
      setStripePromise(
        loadStripe(config.stripe_publishable_key, {
          stripeAccount: config.connected_account_id,
        })
      )
    }
  }, [
    config?.connected_account_id,
    config?.stripe_publishable_key,
    isConfigLoading,
  ])

  return (
    <>
      <h1>Payment</h1>
      {!isPaymentIdLoading && stripePromise && !isError && (
        <Elements
          stripe={stripePromise}
          options={{
            clientSecret: config.client_secret,
          }}
        >
          <PaymentStep />
        </Elements>
      )}
    </>
  )
}

import { useQuery } from '@tanstack/react-query'
import React, { useState } from 'react'
import { pollRegistrations } from '../../../api/registration/get/poll_registrations'
import { Message } from 'semantic-ui-react'

const REFETCH_INTERVAL = 3000

export default function Processing({ processing, setProcessing }) {
  const [pollCounter, setPollCounter] = useState(0)
  const { data } = useQuery({
    queryKey: ['registration-status-polling'],
    queryFn: async () => pollRegistrations(),
    refetchInterval: REFETCH_INTERVAL,
    enabled: processing,
    onSuccess: () => {
      setPollCounter(pollCounter + 1)
    },
  })
  if (
    data &&
    (data.status.payment === 'initialized' ||
      data.status.competing === 'incoming')
  ) {
    setProcessing(false)
  }
  return (
    processing && (
      <div>
        <div>Your registration is processing...</div>
        <div>{data && `Registration status: ${data.status.competing}`}</div>
        <div>
          {pollCounter > 3 && (
            <Message warning>
              Processing is taken longer than usual, don't got away!
            </Message>
          )}
        </div>
        <div>
          {data && data.queueCount > 500 && (
            <Message warning>
              Lots of Registrations being processed, hang tight!
            </Message>
          )}
        </div>
      </div>
    )
  )
}

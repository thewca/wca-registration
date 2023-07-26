import { useQuery } from '@tanstack/react-query'
import React, { useEffect, useState } from 'react'
import { Message } from 'semantic-ui-react'
import { pollRegistrations } from '../../../api/registration/get/poll_registrations'

const REFETCH_INTERVAL = 3000

export default function Processing({ onProcessingComplete }) {
  const [pollCounter, setPollCounter] = useState(0)
  const { data } = useQuery({
    queryKey: ['registration-status-polling'],
    queryFn: async () => pollRegistrations(),
    refetchInterval: REFETCH_INTERVAL,
    onSuccess: () => {
      setPollCounter(pollCounter + 1)
    },
  })
  useEffect(() => {
    if (
      data &&
      (data.status.payment === 'initialized' ||
        data.status.competing === 'incoming')
    ) {
      onProcessingComplete()
    }
  }, [data, onProcessingComplete])
  return (
    <div>
      <div>Your registration is processing...</div>
      <div>{data && `Registration status: ${data.status.competing}`}</div>
      <div>
        {pollCounter > 3 && (
          <Message warning>
            Processing is taking longer than usual, don't go away!
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
}

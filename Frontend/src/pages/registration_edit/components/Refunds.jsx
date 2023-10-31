import { useMutation, useQuery } from '@tanstack/react-query'
import React, { useContext } from 'react'
import { useParams } from 'react-router-dom'
import { Button, Input, Label, Modal, Table } from 'semantic-ui-react'
import { CompetitionContext } from '../../../api/helper/context/competition_context'
import getAvailableRefunds from '../../../api/payment/get/get_available_refunds'
import refundPayment from '../../../api/payment/get/refund_payment'
import { setMessage } from '../../../ui/events/messages'

export default function Refunds({ open, onExit }) {
  const { user_id } = useParams()
  const { competitionInfo } = useContext(CompetitionContext)
  const { data: refunds } = useQuery({
    queryKey: ['refunds', competitionInfo.id, user_id],
    queryFn: () => getAvailableRefunds(user_id, competitionInfo.id),
    refetchOnWindowFocus: false,
    refetchOnReconnect: false,
    staleTime: Infinity,
    refetchOnMount: 'always',
  })
  const { mutate: refundMutation, isLoading } = useMutation({
    mutationFn: refundPayment,
    onError: (data) => {
      setMessage(
        'Refund payment failed with error: ' + data.errorCode,
        'negative'
      )
    },
    onSuccess: () => {
      setMessage('Refund succeeded', 'positive')
      onExit()
    },
  })
  return (
    <Modal open={open} dimmer="blurring">
      Available Refunds:
      <Table>
        <Table.Header>
          <Table.Header> Amount </Table.Header>
          <Table.Header> </Table.Header>
        </Table.Header>
        <Table.Body>
          {refunds.charges.map((refund) => (
            <Table.Row key={refund.payment_id}>
              <Table.Cell>
                <Input labelPosition="right" type="text" placeholder="Amount">
                  <Label basic>$</Label>
                  <input max={refund.amount} />
                </Input>
              </Table.Cell>
              <Table.Cell>
                <Button
                  onClick={() =>
                    refundMutation(
                      competitionInfo.id,
                      user_id,
                      refund.payment_id
                    )
                  }
                >
                  Refund amount
                </Button>
              </Table.Cell>
            </Table.Row>
          ))}
        </Table.Body>
      </Table>
      <Button disabled={isLoading} onClick={onExit}>
        Go Back
      </Button>
    </Modal>
  )
}

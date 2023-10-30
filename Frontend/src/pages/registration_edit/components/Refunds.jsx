import { useQuery } from '@tanstack/react-query'
import React, { useContext } from 'react'
import { useParams } from 'react-router-dom'
import { Button, Modal, Table } from 'semantic-ui-react'
import { CompetitionContext } from '../../../api/helper/context/competition_context'
import getAvailableRefunds from '../../../api/payment/get/get_available_refunds'
import refundPayment from '../../../api/payment/get/refund_payment'

export default function Refunds({ onExit }) {
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
  return (
    <Modal dimmer="blurring">
      Available Refunds:
      <Table>
        <Table.Header>
          <Table.Header> Amount </Table.Header>
          <Table.Header> </Table.Header>
        </Table.Header>
        <Table.Body>
          {refunds.charges.map((refund) => (
            <Table.Row key={refund.payment_id}>
              <Table.Cell> {refund.amount} </Table.Cell>
              <Table.Cell>
                <Button
                  onClick={() =>
                    refundPayment(
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
      <Button onClick={onExit}>Go Back</Button>
    </Modal>
  )
}

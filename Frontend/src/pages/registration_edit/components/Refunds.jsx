import { useMutation, useQuery } from '@tanstack/react-query'
import React, { useState } from 'react'
import { useTranslation } from 'react-i18next'
import { Button, Input, Label, Modal, Table } from 'semantic-ui-react'
import getAvailableRefunds from '../../../api/payment/get/get_available_refunds'
import refundPayment from '../../../api/payment/get/refund_payment'
import { setMessage } from '../../../ui/events/messages'
import LoadingMessage from '../../../ui/messages/loadingMessage'

export default function Refunds({ open, onExit, userId, competitionId }) {
  const [refundAmount, setRefundAmount] = useState(0)

  const { t } = useTranslation()

  const {
    data: refunds,
    isLoading: refundsLoading,
    isError: refundError,
  } = useQuery({
    queryKey: ['refunds', competitionId, userId],
    queryFn: () => getAvailableRefunds(competitionId, userId),
    refetchOnWindowFocus: false,
    refetchOnReconnect: false,
    staleTime: Infinity,
    refetchOnMount: 'always',
  })
  const { mutate: refundMutation, isLoading: isMutating } = useMutation({
    mutationFn: refundPayment,
    onError: (data) => {
      setMessage(
        'Refund payment failed with error: ' + data.errorCode,
        'negative',
      )
    },
    onSuccess: () => {
      setMessage('Refund succeeded', 'positive')
      onExit()
    },
  })
  return refundsLoading ? (
    <LoadingMessage />
  ) : (
    !refundError && (
      <Modal open={open} dimmer="blurring">
        <Modal.Header>Available Refunds:</Modal.Header>
        <Modal.Content>
          <Table>
            <Table.Header>
              <Table.Header>{t('')}</Table.Header>
              <Table.Header> </Table.Header>
            </Table.Header>
            <Table.Body>
              {refunds.charges.map((refund) => (
                <Table.Row key={refund.payment_id}>
                  <Table.Cell>
                    <Input
                      labelPosition="right"
                      type="text"
                      placeholder={refund.amount}
                    >
                      <Label basic>$</Label>
                      <input
                        value={refundAmount}
                        max={refund.amount}
                        onChange={(event) =>
                          setRefundAmount(event.target.value)
                        }
                      />
                    </Input>
                  </Table.Cell>
                  <Table.Cell>
                    <Button
                      onClick={() =>
                        refundMutation({
                          competitionId,
                          userId,
                          paymentId: refund.payment_id,
                          amount: refundAmount,
                        })
                      }
                    >
                      {t('registrations.refund_form.labels.refund_amount')}
                    </Button>
                  </Table.Cell>
                </Table.Row>
              ))}
            </Table.Body>
          </Table>
        </Modal.Content>
        <Modal.Actions>
          <Button disabled={isMutating} onClick={onExit}>
            {t('en.competitions.registration_v2.refunds.back')}
          </Button>
        </Modal.Actions>
      </Modal>
    )
  )
}

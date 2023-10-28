import * as currencies from '@dinero.js/currencies'
import { UiIcon } from '@thewca/wca-components'
import { dinero, toDecimal } from 'dinero.js'
import { marked } from 'marked'
import moment from 'moment/moment'
import React, { useContext, useState } from 'react'
import { Accordion, Header, Segment } from 'semantic-ui-react'
import { CompetitionContext } from '../../../api/helper/context/competition_context'

export default function RegistrationRequirements() {
  const { competitionInfo } = useContext(CompetitionContext)
  const [activeIndex, setActiveIndex] = useState(-1)
  const handleClick = (e, titleProps) => {
    const { index } = titleProps
    setActiveIndex(activeIndex === index ? -1 : index)
  }
  return (
    <>
      <Header as="h1" attached="top">
        Registration Requirements
        <Header.Subheader>
          [INSERT ORGANIZER MESSAGE REGARDING REQUIREMENTS]
        </Header.Subheader>
      </Header>
      <Segment padded inverted color="orange" attached size="big">
        <Accordion inverted>
          <Accordion.Title
            active={activeIndex === 0}
            index={0}
            onClick={handleClick}
          >
            <UiIcon name="dropdown" />
            WCA Account Required
          </Accordion.Title>
          <Accordion.Content active={activeIndex === 0}>
            <p>
              You need a WCA Account to register, click{' '}
              <a href="/users/sign_up">here</a> to create One
            </p>
          </Accordion.Content>
          <Accordion.Title
            active={activeIndex === 1}
            index={1}
            onClick={handleClick}
          >
            <UiIcon name="dropdown" />
            {competitionInfo.competitor_limit} person Competitor Limit
          </Accordion.Title>
          <Accordion.Content active={activeIndex === 1}>
            <p>
              Once the competitor Limit has been reached you will be put onto
              the waiting list
            </p>
          </Accordion.Content>
          <Accordion.Title
            active={activeIndex === 2}
            index={2}
            onClick={handleClick}
          >
            <UiIcon name="dropdown" />
            {competitionInfo.refund_policy_percent === 0
              ? 'No refunds'
              : `${
                  competitionInfo.refund_policy_percent
                }% Refund before ${moment(
                  competitionInfo.refund_policy_limit_date ??
                    competitionInfo.start_date
                ).format('ll')}`}
          </Accordion.Title>
          <Accordion.Content active={activeIndex === 2}>
            <p>
              You will get a {competitionInfo.refund_policy_percent}% refund
              before this date.
            </p>
          </Accordion.Content>
          <Accordion.Title
            active={activeIndex === 3}
            index={3}
            onClick={handleClick}
          >
            <UiIcon name="dropdown" />
            Edit Registration until{' '}
            {moment(
              competitionInfo.event_change_deadline_date ??
                competitionInfo.end_date
            ).format('ll')}
          </Accordion.Title>
          <Accordion.Content active={activeIndex === 3}>
            <p>You can edit your registration until this date</p>
          </Accordion.Content>
          <Accordion.Title
            active={activeIndex === 4}
            index={4}
            onClick={handleClick}
          >
            <UiIcon name="dropdown" />
            {competitionInfo.base_entry_fee_lowest_denomination
              ? `${toDecimal(
                  dinero({
                    amount: competitionInfo.base_entry_fee_lowest_denomination,
                    currency: currencies[competitionInfo.currency_code],
                  }),
                  ({ value, currency }) => `${currency.code} ${value}`
                )} registration fee`
              : 'No registration fee'}
          </Accordion.Title>
          <Accordion.Content active={activeIndex === 4}>
            <p>
              {competitionInfo.base_entry_fee_lowest_denomination
                ? // eslint-disable-next-line unicorn/no-nested-ternary
                  competitionInfo['using_stripe_payments?']
                  ? 'You will have to pay the registration fee on stripe after registering'
                  : 'Check the Additional Registration Requirements about how to pay'
                : 'This competition is free'}
            </p>
          </Accordion.Content>
          <Accordion.Title
            active={activeIndex === 5}
            index={5}
            onClick={handleClick}
          >
            <UiIcon name="dropdown" />
            {competitionInfo.guests_entry_fee_lowest_denomination
              ? `${toDecimal(
                  dinero({
                    amount:
                      competitionInfo.guests_entry_fee_lowest_denomination,
                    currency: currencies[competitionInfo.currency_code],
                  }),
                  ({ value, currency }) => `${currency.code} ${value}`
                )} fee for attending guests`
              : 'No guest fee'}
          </Accordion.Title>
          <Accordion.Content active={activeIndex === 5}>
            <p>
              {competitionInfo.guests_entry_fee_lowest_denomination
                ? 'Guests have to pay this amount to attend'
                : 'Guests attend for free'}
            </p>
          </Accordion.Content>
          {competitionInfo.extra_registration_requirements && (
            <>
              <Accordion.Title
                active={activeIndex === 6}
                index={6}
                onClick={handleClick}
              >
                <UiIcon name="dropdown" />
                Additional Registration Requirements
              </Accordion.Title>
              <Accordion.Content active={activeIndex === 6}>
                <p
                  dangerouslySetInnerHTML={{
                    __html: marked(
                      competitionInfo.extra_registration_requirements
                    ),
                  }}
                />
              </Accordion.Content>{' '}
            </>
          )}
        </Accordion>
      </Segment>
    </>
  )
}

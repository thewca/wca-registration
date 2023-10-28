import { UiIcon } from '@thewca/wca-components'
import moment from 'moment/moment'
import React, { useContext } from 'react'
import { Header, Popup, Segment } from 'semantic-ui-react'
import { CompetitionContext } from '../../../api/helper/context/competition_context'

export default function RegistrationRequirements() {
  const { competitionInfo } = useContext(CompetitionContext)
  return (
    <Segment padded="very" inverted color="orange" attached size="big">
      <Popup
        position="top right"
        content="You need a WCA Account to register"
        trigger={
          <Header>
            WCA Account Required <UiIcon name="circle info" />
          </Header>
        }
      />
      <br />
      <Popup
        position="top right"
        content="Once the competitor Limit has been reached you will be put onto the waiting list"
        trigger={
          <Header>
            {competitionInfo.competitor_limit} Competitor Limit{' '}
            <UiIcon name="circle info" />
          </Header>
        }
      />
      <br />
      <Popup
        position="top right"
        content="You will get a full refund before this date"
        trigger={
          <Header>
            Full Refund before{' '}
            {moment(
              competitionInfo.refund_policy_limit_date ??
                competitionInfo.start_date
            ).format('ll')}
            <UiIcon name="circle info" />
          </Header>
        }
      />
      <br />
      <Popup
        content="You can edit your registration until this date"
        position="top right"
        trigger={
          <Header>
            Edit Registration until{' '}
            {moment(
              competitionInfo.event_change_deadline_date ??
                competitionInfo.end_date
            ).format('ll')}
            <UiIcon name="circle info" />
          </Header>
        }
      />
    </Segment>
  )
}

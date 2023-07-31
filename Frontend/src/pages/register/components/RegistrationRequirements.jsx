import { UiIcon } from '@thewca/wca-components'
import moment from 'moment/moment'
import { useContext } from 'react'
import React from 'react/react.shared-subset'
import { Popup } from 'semantic-ui-react'
import { CompetitionContext } from '../../../api/helper/context/competition_context'
import styles from './requirements.module.scss'

export default function RegistrationRequirements() {
  const { competitionInfo } = useContext(CompetitionContext)
  return (
    <div className={styles.requirementText}>
      <Popup
        position="top right"
        content="You need a WCA Account to register"
        trigger={
          <span>
            WCA Account Required <UiIcon name="circle info" />
          </span>
        }
      />
      <br />
      <Popup
        position="top right"
        content="Once the competitor Limit has been reached you will be put onto the waiting list"
        trigger={
          <span>
            {competitionInfo.competitor_limit} Competitor Limit{' '}
            <UiIcon name="circle info" />
          </span>
        }
      />
      <br />
      <Popup
        position="top right"
        content="You will get a full refund before this date"
        trigger={
          <span>
            Full Refund before{' '}
            {moment(
              competitionInfo.refund_policy_limit_date ??
                competitionInfo.start_date
            ).format('ll')}
            <UiIcon name="circle info" />
          </span>
        }
      />
      <br />
      <Popup
        content="You can edit your registration until this date"
        position="top right"
        trigger={
          <span>
            Edit Registration until{' '}
            {moment(
              competitionInfo.event_change_deadline_date ??
                competitionInfo.end_date
            ).format('ll')}
            <UiIcon name="circle info" />
          </span>
        }
      />
    </div>
  )
}

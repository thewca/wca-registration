import { UiIcon } from '@thewca/wca-components'
import moment from 'moment'
import React, { useContext } from 'react'
import { Message, Popup } from 'semantic-ui-react'
import { CAN_ATTEND_COMPETITIONS } from '../../api/auth/get_permissions'
import { CompetitionContext } from '../../api/helper/context/competition_context'
import { PermissionsContext } from '../../api/helper/context/permission_context'
import { UserContext } from '../../api/helper/context/user_context'
import PermissionMessage from '../../ui/messages/permissionMessage'
import RegistrationPanel from './components/RegistrationPanel'
import styles from './index.module.scss'

export default function Register() {
  const { user } = useContext(UserContext)
  const { competitionInfo } = useContext(CompetitionContext)
  const { canAttendCompetition } = useContext(PermissionsContext)
  const loggedIn = user !== null
  return (
    <div>
      <div className={styles.requirements}>
        <div className={styles.requirementsHeader}>
          Registration Requirements
        </div>
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
      </div>
      {!loggedIn ? (
        <h2>You have to log in to Register for a Competition</h2>
      ) : // eslint-disable-next-line unicorn/no-nested-ternary
      competitionInfo['registration_opened?'] ? (
        <div>
          <div className={styles.registrationHeader}>Hi, {user.name}</div>
          {canAttendCompetition ? (
            <RegistrationPanel />
          ) : (
            <PermissionMessage permissionLevel={CAN_ATTEND_COMPETITIONS} />
          )}
        </div>
      ) : (
        <div className={styles.competitionNotOpen}>
          <Message warning>
            {moment(competitionInfo.registration_open).diff(moment.now()) < 0
              ? `Competition Registration closed on ${moment(
                  competitionInfo.registration_close
                ).format('ll')}`
              : `Competition Registration will open in ${moment(
                  competitionInfo.registration_open
                ).fromNow()} on ${moment(
                  competitionInfo.registration_open
                ).format('lll')}`}
          </Message>
        </div>
      )}
    </div>
  )
}

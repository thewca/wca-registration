import { UiIcon } from '@thewca/wca-components'
import React, { useContext } from 'react'
import { Popup } from 'semantic-ui-react'
import {
  CAN_ATTEND_COMPETITIONS,
  canAttendCompetitions,
} from '../../api/auth/get_permissions'
import { AuthContext } from '../../api/helper/context/auth_context'
import { CompetitionContext } from '../../api/helper/context/competition_context'
import PermissionMessage from '../../ui/messages/permissionMessage'
import RegistrationPanel from './components/RegistrationPanel'
import styles from './index.module.scss'

export default function Register() {
  const { user } = useContext(AuthContext)
  const { competitionInfo } = useContext(CompetitionContext)
  const loggedIn = user !== null

  return (
    <div>
      <div className={styles.requirements}>
        <div className={styles.requirementsHeader}>
          Registration Requirements
        </div>
        <div className={styles.requirementText}>
          <Popup
            content="You need a WCA Account to register"
            trigger={
              <span>
                WCA Account Required <UiIcon name="circle info" />
              </span>
            }
          />
          <br />
          <Popup
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
            content="You will get a full refund before this date"
            trigger={
              <span>
                Full Refund before{' '}
                {new Date(
                  competitionInfo.registration_close
                ).toLocaleDateString()}
                <UiIcon name="circle info" />
              </span>
            }
          />
          <br />
          <Popup
            content="You can edit your registration until this date"
            trigger={
              <span>
                Edit Registration until{' '}
                {new Date(
                  competitionInfo.registration_close
                ).toLocaleDateString()}
                <UiIcon name="circle info" />
              </span>
            }
          />
        </div>
      </div>
      {!loggedIn ? (
        <h2>You have to log in to Register for a Competition</h2>
      ) : (
        <>
          <div className={styles.registrationHeader}>Hi, {user}</div>
          {canAttendCompetitions(user) ? (
            <RegistrationPanel />
          ) : (
            <PermissionMessage permissionLevel={CAN_ATTEND_COMPETITIONS} />
          )}
        </>
      )}
    </div>
  )
}

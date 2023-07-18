import { UiIcon } from '@thewca/wca-components'
import React, { useContext } from 'react'
import { Popup } from 'semantic-ui-react'
import { CAN_ATTEND_COMPETITIONS } from '../../api/auth/get_permissions'
import { UserContext } from '../../api/helper/context/user_context'
import { CompetitionContext } from '../../api/helper/context/competition_context'
import PermissionMessage from '../../ui/messages/permissionMessage'
import RegistrationPanel from './components/RegistrationPanel'
import styles from './index.module.scss'
import { PermissionsContext } from '../../api/helper/context/permission_context'

export default function Register() {
  const { user } = useContext(UserContext)
  const { competitionInfo } = useContext(CompetitionContext)
  const { canAttendCompetitions } = useContext(PermissionsContext)
  const loggedIn = user !== undefined

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
            position="top right"
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
          <div className={styles.registrationHeader}>Hi, {user.name}</div>
          {canAttendCompetitions() ? (
            <RegistrationPanel />
          ) : (
            <PermissionMessage permissionLevel={CAN_ATTEND_COMPETITIONS} />
          )}
        </>
      )}
    </div>
  )
}

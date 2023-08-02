import moment from 'moment'
import React, { useContext } from 'react'
import { Message, Popup } from 'semantic-ui-react'
import { CAN_ATTEND_COMPETITIONS } from '../../api/auth/get_permissions'
import { CompetitionContext } from '../../api/helper/context/competition_context'
import { PermissionsContext } from '../../api/helper/context/permission_context'
import { UserContext } from '../../api/helper/context/user_context'
import PermissionMessage from '../../ui/messages/permissionMessage'
import RegistrationRequirements from './components/RegistrationRequirements'
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
        <RegistrationRequirements />
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

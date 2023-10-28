import moment from 'moment'
import React, { useContext } from 'react'
import { Header, Message } from 'semantic-ui-react'
import { CompetitionContext } from '../../api/helper/context/competition_context'
import { PermissionsContext } from '../../api/helper/context/permission_context'
import { UserContext } from '../../api/helper/context/user_context'
import PermissionMessage from '../../ui/messages/permissionMessage'
import RegistrationRequirements from './components/RegistrationRequirements'
import StepPanel from './components/StepPanel'
import styles from './index.module.scss'

export default function Register() {
  const { user } = useContext(UserContext)
  const { competitionInfo } = useContext(CompetitionContext)
  const { canAttendCompetition } = useContext(PermissionsContext)
  const loggedIn = user !== null
  return (
    <div>
      <div className={styles.requirements}>
        <Header as="h1" attached="top">
          Registration Requirements
        </Header>
        <RegistrationRequirements />
      </div>
      {!loggedIn ? (
        <PermissionMessage>
          You need to log in to Register for a competition
        </PermissionMessage>
      ) : // eslint-disable-next-line unicorn/no-nested-ternary
      competitionInfo['registration_opened?'] ? (
        <div>
          <Header>Hi, {user.name}</Header>
          {canAttendCompetition ? (
            <StepPanel />
          ) : (
            <PermissionMessage>
              You are not allowed to Register for a competition, make sure your
              profile is complete and you are not banned
            </PermissionMessage>
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

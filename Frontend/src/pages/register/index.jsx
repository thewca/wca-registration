import React, { useContext } from 'react'
import {
  CAN_ATTEND_COMPETITIONS,
  canAttendCompetitions,
} from '../../api/auth/get_permissions'
import { AuthContext } from '../../api/helper/context/auth_context'
import PermissionMessage from '../../ui/messages/permissionMessage'
import RegistrationPanel from './components/RegistrationPanel'
import styles from './index.module.scss'

export default function Register() {
  const { user } = useContext(AuthContext)
  const loggedIn = user !== null

  return (
    <div className={styles.container}>
      {!loggedIn ? (
        <h2>You have to log in to Register for a Competition</h2>
      ) : (
        <>
          <h2>Hi, {user}</h2>
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

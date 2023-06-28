import React, { useContext } from 'react'
import { useParams } from 'react-router-dom'
import {
  CAN_ADMINISTER_COMPETITIONS,
  canAdminCompetition,
} from '../../api/auth/get_permissions'
import { AuthContext } from '../../api/helper/context/auth_context'
import PermissionMessage from '../../ui/messages/permissionMessage'
import RegistrationEditor from './components/RegistrationEditor'
import styles from './index.module.scss'

export default function RegistrationEdit() {
  const { competition_id, user_id } = useParams()
  const { user } = useContext(AuthContext)
  return (
    <div className={styles.container}>
      {canAdminCompetition(user, competition_id) ? (
        <RegistrationEditor competition_id={competition_id} user_id={user_id} />
      ) : (
        <PermissionMessage permissionLevel={CAN_ADMINISTER_COMPETITIONS} />
      )}
    </div>
  )
}

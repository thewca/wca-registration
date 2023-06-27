import React, { useContext } from 'react'
import { useParams } from 'react-router-dom'
import {
  CAN_ADMINISTER_COMPETITIONS,
  canAdminCompetition,
} from '../../api/auth/get_permissions'
import { AuthContext } from '../../api/helper/context/auth_context'
import RegistrationAdministrationList from './components/RegistrationAdministrationList'
import styles from './index.module.scss'
import PermissionMessage from '../../ui/Messages/permissionMessage'

export default function RegistrationAdministration() {
  const { competition_id } = useParams()
  const { user } = useContext(AuthContext)
  return (
    <div className={styles.container}>
      {canAdminCompetition(competition_id, user) ? (
        <RegistrationAdministrationList />
      ) : (
        <PermissionMessage permissionLevel={CAN_ADMINISTER_COMPETITIONS} />
      )}
    </div>
  )
}

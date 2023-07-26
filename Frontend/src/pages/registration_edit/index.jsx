import React, { useContext } from 'react'
import { CAN_ADMINISTER_COMPETITIONS } from '../../api/auth/get_permissions'
import { PermissionsContext } from '../../api/helper/context/permission_context'
import PermissionMessage from '../../ui/messages/permissionMessage'
import RegistrationEditor from './components/RegistrationEditor'
import styles from './index.module.scss'

export default function RegistrationEdit() {
  const { canAdminCompetition } = useContext(PermissionsContext)
  return (
    <div className={styles.container}>
      {canAdminCompetition ? (
        <RegistrationEditor />
      ) : (
        <PermissionMessage permissionLevel={CAN_ADMINISTER_COMPETITIONS} />
      )}
    </div>
  )
}

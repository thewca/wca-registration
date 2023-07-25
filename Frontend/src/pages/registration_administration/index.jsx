import React, { useContext } from 'react'
import { CAN_ADMINISTER_COMPETITIONS } from '../../api/auth/get_permissions'
import { PermissionsContext } from '../../api/helper/context/permission_context'
import PermissionMessage from '../../ui/messages/permissionMessage'
import RegistrationAdministrationList from './components/RegistrationAdministrationList'

export default function RegistrationAdministration() {
  const { canAdminCompetition } = useContext(PermissionsContext)
  return (
    <div>
      {canAdminCompetition ? (
        <RegistrationAdministrationList />
      ) : (
        <PermissionMessage permissionLevel={CAN_ADMINISTER_COMPETITIONS} />
      )}
    </div>
  )
}

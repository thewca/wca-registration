import React, { useContext } from 'react'
import { PermissionsContext } from '../../api/helper/context/permission_context'
import PermissionMessage from '../../ui/messages/permissionMessage'
import RegistrationEditor from './components/RegistrationEditor'

export default function RegistrationEdit() {
  const { canAdminCompetition } = useContext(PermissionsContext)
  return (
    <div>
      {canAdminCompetition ? (
        <RegistrationEditor />
      ) : (
        <PermissionMessage>
          You are not allowed to administrate this competition
        </PermissionMessage>
      )}
    </div>
  )
}

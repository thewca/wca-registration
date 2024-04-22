import React, { useContext } from 'react'
import { PermissionsContext } from '../../api/helper/context/permission_context'
import { NotAuthorizedPermissionMessage } from '../../ui/messages/permissionMessage'
import RegistrationEditor from './components/RegistrationEditor'

export default function RegistrationEdit() {
  const { canAdminCompetition } = useContext(PermissionsContext)
  return (
    <div>
      {canAdminCompetition ? (
        <RegistrationEditor />
      ) : (
        <NotAuthorizedPermissionMessage />
      )}
    </div>
  )
}

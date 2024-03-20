import React, { useContext } from 'react'
import { Segment } from 'semantic-ui-react'
import { PermissionsContext } from '../../api/helper/context/permission_context'
import { NotAuthorizedPermissionMessage } from '../../ui/messages/permissionMessage'
import RegistrationAdministrationList from './components/RegistrationAdministrationList'

export default function RegistrationAdministration() {
  const { canAdminCompetition } = useContext(PermissionsContext)
  return (
    <div>
      {canAdminCompetition ? (
        <Segment padded attached>
          <RegistrationAdministrationList />
        </Segment>
      ) : (
        <NotAuthorizedPermissionMessage />
      )}
    </div>
  )
}

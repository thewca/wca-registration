import React, { useContext } from 'react'
import { PermissionsContext } from '../../api/helper/context/permission_context'
import PermissionMessage from '../../ui/messages/permissionMessage'
import RegistrationAdministrationList from './components/RegistrationAdministrationList'
import {Segment} from "semantic-ui-react";

export default function RegistrationAdministration() {
  const { canAdminCompetition } = useContext(PermissionsContext)
  return (
    <div>
      {canAdminCompetition ? (
        <Segment padded attached>
          <RegistrationAdministrationList />
        </Segment>
      ) : (
        <PermissionMessage>
          You are not allowed to administrate this competition
        </PermissionMessage>
      )}
    </div>
  )
}

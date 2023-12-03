import { useMutation } from '@tanstack/react-query'
import React, { useContext, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { Button, Input, Segment } from 'semantic-ui-react'
import { CompetitionContext } from '../../api/helper/context/competition_context'
import { PermissionsContext } from '../../api/helper/context/permission_context'
import importRegistration from '../../api/registration/post/import_registration'
import { BASE_ROUTE } from '../../routes'
import PermissionMessage from '../../ui/messages/permissionMessage'

export default function Import() {
  const [file, setFile] = useState();

  const navigate = useNavigate()

  const { competitionInfo } = useContext(CompetitionContext)
  const { canAdminCompetition } = useContext(PermissionsContext)

  const { mutate: importMutation, isLoading: isMutating } = useMutation({
    mutationFn: importRegistration,
    onSuccess: () =>
      navigate(`${BASE_ROUTE}/${competitionInfo.id}/registrations/edit`),
  })

  return !canAdminCompetition ? (
    <PermissionMessage>
      You are not allowed to import registrations.
    </PermissionMessage>
  ) : (
    <Segment attached padded>
      <Input
        type="file"
        accept="text/csv"
        onChange={(event) => setFile(event.target.files[0])}
      />
      <Button
        disabled={!file || isMutating}
        onClick={() =>
          importMutation({ competitionId: competitionInfo.id, file })
        }
      >
        Upload CSV
      </Button>
    </Segment>
  )
}

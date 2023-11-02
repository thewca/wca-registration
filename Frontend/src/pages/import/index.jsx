import { useMutation } from '@tanstack/react-query'
import { useContext, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { Button, Input, Segment } from 'semantic-ui-react'
import { PermissionsContext } from '../../api/helper/context/permission_context'
import importRegistration from '../../api/registration/post/import_registration'
import { BASE_ROUTE } from '../../routes'
import PermissionMessage from '../../ui/messages/permissionMessage'

export default function Import() {
  const [file, setFile] = useState()
  const navigate = useNavigate()
  const { competitionInfo } = useContext(competitionInfo)
  const { canAdminCompetition } = useContext(PermissionsContext)
  const { mutate: importMutation, isLoading: isMutating } = useMutation({
    mutationFn: importRegistration,
    onSuccess: () =>
      navigate(`${BASE_ROUTE}/${competitionInfo.id}/registrations`),
  })
  return !canAdminCompetition ? (
    <PermissionMessage>
      You are not allowed to import registrations.
    </PermissionMessage>
  ) : (
    <Segment>
      <Input
        type="file"
        onChange={(event) => {
          const file = event.target.files[0]
          if (!file.name.endsWith('.csv')) {
            // TODO: This is just for testing
            // eslint-disable-next-line no-alert
            alert('Only .csv files are allowed to be imported')
          } else {
            setFile(file)
          }
        }}
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

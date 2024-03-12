import { useMutation } from '@tanstack/react-query'
import React, { useContext, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { useNavigate } from 'react-router-dom'
import { Button, Input, Segment } from 'semantic-ui-react'
import { CompetitionContext } from '../../api/helper/context/competition_context'
import { PermissionsContext } from '../../api/helper/context/permission_context'
import importRegistration from '../../api/registration/post/import_registration'
import i18n, { TRANSLATIONS_NAMESPACE } from '../../i18n'
import { BASE_ROUTE } from '../../routes'
import { NotAuthorizedPermissionMessage } from '../../ui/messages/permissionMessage'

export default function Import() {
  const [file, setFile] = useState()

  const navigate = useNavigate()

  const { competitionInfo } = useContext(CompetitionContext)
  const { canAdminCompetition } = useContext(PermissionsContext)

  const { t } = useTranslation(TRANSLATIONS_NAMESPACE, { i18n })

  const { mutate: importMutation, isLoading: isMutating } = useMutation({
    mutationFn: importRegistration,
    onSuccess: () =>
      navigate(`${BASE_ROUTE}/${competitionInfo.id}/registrations/edit`),
  })

  return !canAdminCompetition ? (
    <NotAuthorizedPermissionMessage />
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
        {t('registrations.import.import')}
      </Button>
    </Segment>
  )
}

import { UiIcon } from '@thewca/wca-components'
import React from 'react'
import { useTranslation } from 'react-i18next'
import { Message } from 'semantic-ui-react'
import i18n from '../../i18n'

export default function PermissionMessage({ i18nKey }) {
  const { t } = useTranslation('translation', { i18n })

  return (
    <Message icon negative>
      <UiIcon name="lock" size="4x" />
      <Message.Content>
        <Message.Header>Unauthorized</Message.Header>
        {t(i18nKey)}
      </Message.Content>
    </Message>
  )
}

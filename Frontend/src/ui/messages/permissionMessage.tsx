import { UiIcon } from '@thewca/wca-components'
import React from 'react'
import { useTranslation } from 'react-i18next'
import { Message } from 'semantic-ui-react'
import { UserFull } from '../../api/helper/context/user_context'
import i18n from '../../i18n'

interface PermissionMessageProps {
  i18nKey: string
}

export function PermissionMessage({ i18nKey }: PermissionMessageProps) {
  const { t } = useTranslation(undefined, { i18n })

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

export function NotAuthorizedPermissionMessage() {
  return (
    <PermissionMessage i18nKey="competitions.registration_v2.errors.-2003" />
  )
}

interface RegistrationPermissionMessageParams {
  loggedIn: boolean
  userInfo: UserFull
}
export function RegistrationPermissionMessage({
  loggedIn,
  userInfo,
}: RegistrationPermissionMessageParams) {
  let key = ''
  if (!loggedIn) {
    key = 'registrations.please_sign_in_html'
  }
  if (!userInfo.name) {
    key = 'registrations.errors.need_name'
  }
  // gender missing
  // eslint-disable-next-line @typescript-eslint/no-unnecessary-condition
  if (!userInfo.gender) {
    key = 'registrations.errors.need_gender'
  }
  if (!userInfo.country_iso2) {
    key = 'registrations.errors.need_country'
  }
  // Missing check: No dob
  return <PermissionMessage i18nKey={key} />
}

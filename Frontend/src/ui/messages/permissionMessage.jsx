import { UiIcon } from '@thewca/wca-components'
import React from 'react'
import { Message } from 'semantic-ui-react'

export default function PermissionMessage({ children }) {
  return (
    <Message icon negative>
      <UiIcon name="lock" size="4x" />
      <Message.Content>
        <Message.Header>Unauthorized</Message.Header>
        {children}
      </Message.Content>
    </Message>
  )
}

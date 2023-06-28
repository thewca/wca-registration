import { UiIcon } from '@thewca/wca-components'
import React from 'react'
import { Message } from 'semantic-ui-react'
import styles from './permission.module.scss'

export default function PermissionMessage({ permissionLevel }) {
  return (
    <Message icon className={styles.permissions} negative>
      <UiIcon name="lock" size="4x" />
      <Message.Content>
        <Message.Header>Unauthorized</Message.Header>
        You need '{permissionLevel}' Permissions to access this content.
      </Message.Content>
    </Message>
  )
}

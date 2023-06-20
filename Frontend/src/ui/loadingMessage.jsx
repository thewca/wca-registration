import { UiIcon } from '@thewca/wca-components'
import React from 'react'
import { Message } from 'semantic-ui-react'
import styles from './loading.module.scss'

export default function LoadingMessage() {
  return (
    <Message icon className={styles.loading}>
      <UiIcon name="circle notched" />
      <Message.Content>
        <Message.Header>Just one second</Message.Header>
        We are fetching that content for you.
      </Message.Content>
    </Message>
  )
}

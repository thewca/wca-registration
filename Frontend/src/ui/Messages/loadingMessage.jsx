import React from 'react'
import { Icon, Message } from 'semantic-ui-react'
import styles from './loading.module.scss'

export default function LoadingMessage() {
  return (
    <Message icon className={styles.loading}>
      <Icon name="circle notched" loading />
      <Message.Content>
        <Message.Header>Just one second</Message.Header>
        We are fetching that content for you.
      </Message.Content>
    </Message>
  )
}

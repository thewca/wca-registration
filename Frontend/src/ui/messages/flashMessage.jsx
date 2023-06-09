import React, { useEffect, useState } from 'react'
import { Message } from 'semantic-ui-react'
import Bus from '../events/Bus'
import styles from './flash.module.scss'

export default function FlashMessage() {
  const [visible, setVisible] = useState(false)
  const [message, setMessage] = useState('')
  const [type, setType] = useState('')

  useEffect(() => {
    const listener = ({ message, type }) => {
      setVisible(true)
      setMessage(message)
      setType(type)
      setTimeout(() => {
        setVisible(false)
        setMessage('')
        setType('')
      }, 4000)
    }
    Bus.addListener('flash', listener)
    return () => {
      Bus.removeListener('flash', listener)
    }
  }, [])
  return (
    <Message
      visible={visible}
      positive={type === 'positive'}
      negative={type === 'negative'}
      className={`${styles.message} ${
        visible ? styles.visible : styles.invisible
      }`}
    >
      {message}
    </Message>
  )
}

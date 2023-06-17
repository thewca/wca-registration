import React from 'react'
import RegistrationEditor from './components/registration_editor'
import styles from './index.module.scss'

export default function RegistrationEdit() {
  return (
    <div className={styles.container}>
      <RegistrationEditor />
    </div>
  )
}

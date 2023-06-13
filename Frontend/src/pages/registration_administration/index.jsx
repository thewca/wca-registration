import React from 'react'
import RegistrationList from './components/RegistrationList'
import styles from './index.module.scss'

export default function RegistrationAdministration() {
  return (
    <div className={styles.container}>
      <RegistrationList />
    </div>
  )
}

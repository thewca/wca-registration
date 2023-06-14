import React from 'react'
import RegistrationAdministrationList from './components/RegistrationAdministrationList'
import styles from './index.module.scss'

export default function RegistrationAdministration() {
  return (
    <div className={styles.container}>
      <RegistrationAdministrationList />
    </div>
  )
}

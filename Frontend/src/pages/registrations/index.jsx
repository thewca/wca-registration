import React from 'react'
import RegistrationList from './components/RegistrationList'
import styles from './index.module.scss'

export default function Registrations() {
  return (
    <div className={styles.container}>
      <div className={styles.listHeader}>Competitors:</div>
      <RegistrationList />
    </div>
  )
}

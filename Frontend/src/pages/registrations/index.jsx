import React from 'react'
import RegistrationList from './components/RegistrationList'
import styles from './index.module.scss'

export default function Registrations() {
  return (
    <div className={styles.container}>
      <h2>Competitors:</h2>
      <RegistrationList />
    </div>
  )
}

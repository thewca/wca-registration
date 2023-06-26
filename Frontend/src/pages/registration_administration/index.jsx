import React from 'react'
import RegistrationAdministrationList from './components/RegistrationAdministrationList'
import styles from './index.module.scss'

export default function RegistrationAdministration() {
  const loggedIn = localStorage.getItem('user_id') !== null
  return (
    <div className={styles.container}>
      {loggedIn ? (
        <RegistrationAdministrationList />
      ) : (
        <span>Please log in first to use this feature</span>
      )}
    </div>
  )
}

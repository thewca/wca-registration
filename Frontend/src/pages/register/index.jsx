import React from 'react'
import RegistrationPanel from './components/RegistrationPanel'
import styles from './index.module.scss'

export default function Register() {
  return (
    <div className={styles.container}>
      <RegistrationPanel />
    </div>
  )
}

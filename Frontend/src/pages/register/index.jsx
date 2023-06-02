import React from 'react'
import { Link } from 'react-router-dom'
import RegistrationPanel from './components/RegistrationPanel'
import styles from './index.module.scss'

export default function Register() {
  return (
    <div className={styles.container}>
      <RegistrationPanel />
      <div className={styles.link}>
        <Link to="/registrations"> Registration List </Link>
      </div>
    </div>
  )
}

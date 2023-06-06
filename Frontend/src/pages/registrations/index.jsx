import React from 'react'
import { Link } from 'react-router-dom'
import RegistrationList from './components/RegistrationList'
import styles from './index.module.scss'

export default function Registrations() {
  return (
    <div className={styles.container}>
      <RegistrationList />
      <div className={styles.link}>
        <Link to="/register"> Register </Link>
      </div>
    </div>
  )
}

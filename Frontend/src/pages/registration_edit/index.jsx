import React from 'react'
import { useParams } from 'react-router-dom'
import RegistrationEditor from './components/registrationEditor'
import styles from './index.module.scss'

export default function RegistrationEdit() {
  const { competition_id, user_id } = useParams()
  const loggedIn = localStorage.getItem('user_id') !== null
  return (
    <div className={styles.container}>
      {loggedIn ? (
        <RegistrationEditor competition_id={competition_id} user_id={user_id} />
      ) : (
        <span>Please log in first to use this feature</span>
      )}
    </div>
  )
}

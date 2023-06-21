import React from 'react'
import { useParams } from 'react-router-dom'
import RegistrationEditor from './components/registrationEditor'
import styles from './index.module.scss'

export default function RegistrationEdit() {
  const { competition_id, user_id } = useParams()
  return (
    <div className={styles.container}>
      <RegistrationEditor competition_id={competition_id} user_id={user_id} />
    </div>
  )
}

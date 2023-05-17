import React from 'react'
import styles from './index.module.scss'
import RegistrationList from '../components/registration_list'
import RegistrationPanel from '../components/registration_panel'

export default function App() {
  return (
    <div className={styles.container}>
      <RegistrationPanel> </RegistrationPanel>
      <RegistrationList />
    </div>
  )
}

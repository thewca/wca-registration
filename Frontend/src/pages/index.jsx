import React from 'react'
import styles from './index.module.scss'
import RegistrationList from './register/components/registration_list'
import RegistrationPanel from './register/components/registration_panel'

export default function App() {
  return (
    <div className={styles.container}>
      <RegistrationPanel> </RegistrationPanel>
      <RegistrationList />
    </div>
  )
}

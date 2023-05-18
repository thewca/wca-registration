import React from 'react'
import RegistrationList from '../components/RegistrationList'
import RegistrationPanel from '../components/RegistrationPanel'
import styles from './index.module.scss'

export default function App() {
  return (
    <div className={styles.container}>
      <RegistrationPanel> </RegistrationPanel>
      <RegistrationList />
    </div>
  )
}

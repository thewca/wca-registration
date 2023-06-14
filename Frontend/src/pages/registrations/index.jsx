import React, { Suspense } from 'react'
import RegistrationList from './components/RegistrationList'
import styles from './index.module.scss'

function Loading() {
  return <h2>🌀 Loading...</h2>
}

export default function Registrations() {
  return (
    <div className={styles.container}>
      <Suspense fallback={Loading}>
        <RegistrationList />
      </Suspense>
    </div>
  )
}

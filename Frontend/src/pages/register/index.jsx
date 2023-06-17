import React, { useEffect, useState } from 'react'
import { useParams } from 'react-router-dom'
import { getSingleRegistration } from '../../api/registration/get/get_registrations'
import LoadingMessage from '../shared/loadingMessage'
import RegistrationEditPanel from './components/RegistrationEditPanel'
import RegistrationPanel from './components/RegistrationPanel'
import styles from './index.module.scss'

export default function Register() {
  // TODO move this to something like /api/v0/me when using the real website
  const user_id = localStorage.getItem('user_id')
  const loggedIn = user_id !== null
  const [isLoading, setIsLoading] = useState(true)
  const { competition_id } = useParams()
  const [registration, setRegistration] = useState({})
  useEffect(() => {
    getSingleRegistration(user_id, competition_id).then((response) => {
      setRegistration(response.registration)
      setIsLoading(false)
    })
  }, [competition_id, user_id])
  return isLoading ? (
    <div className={styles.container}>
      <LoadingMessage />
    </div>
  ) : (
    <div className={styles.container}>
      {!loggedIn ? (
        <h2>You have to log in to Register for a Competition</h2>
      ) : (
        <>
          <h2>Hi, {user_id}</h2>
          {!registration.registration_status ? (
            <>
              <h3> You can register for {competition_id}</h3>
              <RegistrationPanel />
            </>
          ) : (
            <>
              <h3> You have registered for {competition_id}</h3>
              <h4> Your status is: {registration.registration_status} </h4>
              <RegistrationEditPanel registration={registration} />
            </>
          )}
        </>
      )}
    </div>
  )
}

import React, { useEffect, useState } from 'react'
import { useParams } from 'react-router-dom'
import { Button } from 'semantic-ui-react'
import { getSingleRegistration } from '../../api/registration/get/get_registrations'
import { updateRegistration } from '../../api/registration/patch/update_registration'
import { setMessage } from '../../ui/events/messages'
import LoadingMessage from '../../ui/loadingMessage'
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
              <Button
                negative
                onClick={() => {
                  setMessage('Registration is being deleted', 'basic')
                  updateRegistration(user_id, competition_id, 'deleted').then(
                    (response) => {
                      if (response.error) {
                        setMessage(
                          'Deleted Registration failed: ' + response.error,
                          'negative'
                        )
                      } else {
                        setRegistration(response.registration)
                        setMessage(
                          'Successfully deleted Registration',
                          'positive'
                        )
                      }
                    }
                  )
                }}
              >
                Delete Registration
              </Button>
            </>
          )}
        </>
      )}
    </div>
  )
}

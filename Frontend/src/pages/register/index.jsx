import React, { useContext, useEffect, useState } from 'react'
import { useParams } from 'react-router-dom'
import { Button } from 'semantic-ui-react'
import {
  CAN_ATTEND_COMPETITIONS,
  canAttendCompetitions,
} from '../../api/auth/get_permissions'
import { AuthContext } from '../../api/helper/context/auth_context'
import {
  USER_IS_BANNED,
  USER_PROFILE_INCOMPLETE,
} from '../../api/helper/error_codes'
import { getSingleRegistration } from '../../api/registration/get/get_registrations'
import { updateRegistration } from '../../api/registration/patch/update_registration'
import { setMessage } from '../../ui/events/messages'
import LoadingMessage from '../../ui/Messages/loadingMessage'
import PermissionMessage from '../../ui/Messages/permissionMessage'
import RegistrationEditPanel from './components/RegistrationEditPanel'
import RegistrationPanel from './components/RegistrationPanel'
import styles from './index.module.scss'

export default function Register() {
  const { competition_id } = useParams()
  // TODO move this to something like /api/v0/me when using the real website
  const { user } = useContext(AuthContext)
  const loggedIn = user !== null
  const [isLoading, setIsLoading] = useState(true)
  const [registration, setRegistration] = useState({})
  useEffect(() => {
    getSingleRegistration(user, competition_id).then((response) => {
      if (response.error) {
        if (response.error === USER_IS_BANNED) {
          setMessage('You cannot register for this competition: You are banned')
        } else if (response.error === USER_PROFILE_INCOMPLETE) {
          setMessage(
            'You cannot register for this competition: You have an incomplete Profile'
          )
        } else {
          setMessage('Error Loading your registration: ' + response.error)
        }
        setIsLoading(false)
      } else {
        setRegistration(response.registration)
        setIsLoading(false)
      }
    })
  }, [competition_id, user])

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
          <h2>Hi, {user}</h2>
          {canAttendCompetitions(user) ? (
            !registration.registration_status ? (
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
                    updateRegistration(user, competition_id, {
                      status: 'deleted',
                    }).then((response) => {
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
                    })
                  }}
                >
                  Delete Registration
                </Button>
              </>
            )
          ) : (
            <PermissionMessage permissionLevel={CAN_ATTEND_COMPETITIONS} />
          )}
        </>
      )}
    </div>
  )
}

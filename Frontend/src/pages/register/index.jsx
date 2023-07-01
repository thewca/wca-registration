import { useQuery } from '@tanstack/react-query'
import React, { useContext } from 'react'
import { Button, Popup } from 'semantic-ui-react'
import {
  CAN_ATTEND_COMPETITIONS,
  canAttendCompetitions,
} from '../../api/auth/get_permissions'
import { AuthContext } from '../../api/helper/context/auth_context'
import { CompetitionContext } from '../../api/helper/context/competition_context'
import { getSingleRegistration } from '../../api/registration/get/get_registrations'
import { updateRegistration } from '../../api/registration/patch/update_registration'
import { setMessage } from '../../ui/events/messages'
import LoadingMessage from '../../ui/messages/loadingMessage'
import PermissionMessage from '../../ui/messages/permissionMessage'
import RegistrationEditPanel from './components/RegistrationEditPanel'
import RegistrationPanel from './components/RegistrationPanel'
import styles from './index.module.scss'
import { UiIcon } from '@thewca/wca-components'

export default function Register() {
  const { competitionInfo } = useContext(CompetitionContext)
  const { user } = useContext(AuthContext)
  const loggedIn = user !== null
  const { data: registrationRequest, isLoading } = useQuery({
    queryKey: ['registration', user, competitionInfo.id],
    queryFn: () => getSingleRegistration(user, competitionInfo.id),
  })

  return isLoading ? (
    <div className={styles.container}>
      <LoadingMessage />
    </div>
  ) : (
    <div className={styles.container}>
      <div className={styles.requirements}>
        <div className={styles.requirementsHeader}>
          Registration Requirements
        </div>
        <div className={styles.requirementText}>
          <Popup
            content="You need a WCA Account to register"
            trigger={
              <span>
                WCA Account Required <UiIcon name="circle info" />
              </span>
            }
          />
          <br />
          <Popup
            content="Once the competitor Limit has been reached you will be put onto the waiting list"
            trigger={
              <span>
                {competitionInfo.competitor_limit} Competitor Limit{' '}
                <UiIcon name="circle info" />
              </span>
            }
          />
          <br />
          <Popup
            content="You will get a full refund before this date"
            trigger={
              <span>
                Full Refund before{' '}
                {new Date(
                  competitionInfo.registration_close
                ).toLocaleDateString()}
                <UiIcon name="circle info" />
              </span>
            }
          />
          <br />
          <Popup
            content="You can edit your registration until this date"
            trigger={
              <span>
                Edit Registration until{' '}
                {new Date(
                  competitionInfo.registration_close
                ).toLocaleDateString()}
                <UiIcon name="circle info" />
              </span>
            }
          />
        </div>
      </div>
      {!loggedIn ? (
        <h2>You have to log in to Register for a Competition</h2>
      ) : (
        <>
          <div className={styles.registrationHeader}>Hi, {user}</div>
          {canAttendCompetitions(user) ? (
            !registrationRequest.registration.registration_status ? (
              <>
                <h3> You can register for {competitionInfo.name}</h3>
                <RegistrationPanel />
              </>
            ) : (
              <>
                <h3> You have registered for {competitionInfo.id}</h3>
                <h4>
                  {' '}
                  Your status is:{' '}
                  {registrationRequest.registration.registration_status}{' '}
                </h4>
                <RegistrationEditPanel
                  registration={registrationRequest.registration}
                />
                <Button
                  negative
                  onClick={() => {
                    setMessage('Registration is being deleted', 'basic')
                    updateRegistration(user, competitionInfo.id, {
                      status: 'deleted',
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

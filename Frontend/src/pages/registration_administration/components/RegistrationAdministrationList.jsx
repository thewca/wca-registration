import React, { useEffect, useMemo, useState } from 'react'
import { useParams } from 'react-router-dom'
import { getAllRegistrations } from '../../../api/registration/get/get_registrations'
import updateRegistration from '../../../api/registration/patch/update_registration'
import getCompetitorInfo from '../../../api/user/get/get_user_info'
import styles from './list.module.scss'
import StatusDropdown from './StatusDropdown'

const partitionRegistrations = (registrations) => {
  return registrations.reduce(
    (result, registration) => {
      switch (registration.registration_status) {
        case 'waiting':
          result.waiting.push(registration)
          break
        case 'accepted':
          result.accepted.push(registration)
          break
        case 'deleted':
          result.deleted.push(registration)
          break
        default:
          break
      }
      return result
    },
    { waiting: [], accepted: [], deleted: [] }
  )
}

export default function RegistrationAdministrationList() {
  const { competition_id } = useParams()
  const [registrations, setRegistrations] = useState([])
  useEffect(() => {
    getAllRegistrations(competition_id).then(async (registrations) => {
      const regList = []
      for (const registration of registrations) {
        registration.user = (
          await getCompetitorInfo(registration.competitor_id)
        ).user
        regList.push(registration)
      }
      setRegistrations(regList)
    })
  }, [competition_id])

  const { waiting, accepted, deleted } = useMemo(
    () => partitionRegistrations(registrations),
    [registrations]
  )

  return (
    <div className={styles.list}>
      <h2> Incoming registrations </h2>
      <RegistrationAdministrationTable registrations={waiting} />
      <h2> Approved registrations </h2>
      <RegistrationAdministrationTable registrations={accepted} />
      <h2> Deleted registrations </h2>
      <RegistrationAdministrationTable registrations={deleted} />
    </div>
  )
}

function RegistrationAdministrationTable({ registrations }) {
  return (
    <table className="table">
      <thead>
        <tr>
          <th>WCA ID</th>
          <th>Name</th>
          <th>Citizen of</th>
          <th>Registered on</th>
          <th>Number of Events</th>
          <th>Apply Changes</th>
        </tr>
      </thead>
      <tbody>
        {registrations.length > 0 ? (
          registrations.map((registration) => {
            return (
              <RegistrationRow
                key={registration.user.id}
                competitorId={registration.competitor_id}
                name={registration.user.name}
                country={registration.user.country.name}
                registeredOn={registration.registered_on}
                numberOfEvents={registration.event_ids.length}
                initialStatus={registration.registration_status}
              />
            )
          })
        ) : (
          <tr>
            <td colSpan={6}>No matching records found</td>
          </tr>
        )}
      </tbody>
    </table>
  )
}

function RegistrationRow({
  competitorId,
  name,
  country,
  registeredOn,
  numberOfEvents,
  initialStatus,
}) {
  const [status, setStatus] = useState(initialStatus)
  const { competition_id } = useParams()
  return (
    <tr>
      <td>{competitorId}</td>
      <td>{name}</td>
      <td>{country}</td>
      <td>{new Date(registeredOn).toLocaleDateString()}</td>
      <td>{numberOfEvents}</td>
      <td>
        <StatusDropdown status={status} setStatus={setStatus} />
      </td>
      <td>
        <button
          // TODO Update the list automatically
          onClick={(_) => {
            updateRegistration(competitorId, competition_id, status)
          }}
        >
          Apply
        </button>
      </td>
    </tr>
  )
}

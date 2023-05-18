import React, { useState } from 'react'
import deleteRegistration from '../../api/registration/delete/delete_registration'
import getRegistrations from '../../api/registration/get/get_registrations'
import updateRegistration from '../../api/registration/patch/update_registration'
import styles from './list.module.scss'
import StatusDropdown from './StatusDropdown'

function RegistrationRow({
  competitorId,
  eventIDs,
  serverStatus,
  competitionID,
  setRegistrationList,
  registrationList,
}) {
  const [status, setStatus] = useState(serverStatus)

  return (
    <tr>
      <td>{competitorId}</td>
      <td>{eventIDs.join(',')}</td>
      <td>
        <StatusDropdown status={status} setStatus={setStatus} />
      </td>
      <td>
        <button
          onClick={(_) => {
            updateRegistration(competitorId, competitionID, status)
          }}
        >
          {' '}
          Apply
        </button>
      </td>
      <td>
        <button
          onClick={(_) => {
            deleteRegistration(competitorId, competitionID)
            setRegistrationList(
              registrationList.filter((r) => r.competitor_id !== competitorId)
            )
          }}
        >
          Delete
        </button>
      </td>
    </tr>
  )
}

export default function RegistrationList() {
  const [competitionID, setCompetitionID] = useState('HessenOpen2023')
  const [registrationList, setRegistrationList] = useState([])
  return (
    <div className={styles.list}>
      <button
        onClick={async (_) =>
          setRegistrationList(await getRegistrations(competitionID))
        }
      >
        {' '}
        List Registrations
      </button>
      <label>
        Competition_id
        <input
          type="text"
          value={competitionID}
          name="list_competition_id"
          onChange={(e) => setCompetitionID(e.target.value)}
        />
      </label>
      <table>
        <thead>
          <tr>
            <th> Competitor</th>
            <th> Events </th>
            <th> Status </th>
            <th> Apply Changes </th>
            <th> Delete </th>
          </tr>
        </thead>
        <tbody>
          {registrationList.map((registration) => {
            return (
              <RegistrationRow
                key={registration.competitor_id}
                competitorId={registration.competitor_id}
                setRegistrationList={setRegistrationList}
                eventIDs={registration.event_ids}
                competitionID={competitionID}
                serverStatus={registration.registration_status}
                registrationList={registrationList}
              />
            )
          })}
        </tbody>
      </table>
    </div>
  )
}

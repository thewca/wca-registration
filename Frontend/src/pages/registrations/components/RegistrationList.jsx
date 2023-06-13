import React, { useEffect, useState } from 'react'
import { useParams } from 'react-router-dom'
import getRegistrations from '../../../api/registration/get/get_registrations'
import styles from './list.module.scss'
// TODO: Fix the import in the library
import NonInteractiveTable from '@thewca/wca-components/src/components/NonInteractiveTable'

export default function RegistrationList() {
  const { competition_id } = useParams()
  const [registrationList, setRegistrationList] = useState([])
  const [loading, setLoading] = useState(true)
  const held_events = ['333', '444', '555', '777']
  const header = [
    { title: 'Name' },
    { title: 'Citizen of' },
    ...held_events.map((event_id) => {
      return { title: event_id, icon: true }
    }),
    { title: 'Total' },
  ]
  const footer = [
    '0 first-timers + 3 Returners = 3 People',
    '2 Countries',
    '2',
    '2',
    '2',
    '1',
    '',
  ]
  useEffect(() => {
    getRegistrations(competition_id).then((registrations) => {
      const rows = registrations.map((registration) => {
        return [
          {
            title: registration.competitor_id,
            link: `https://www.worldcubeassociation.org/persons/${registration.competitor_id}`,
          },
          {
            title: 'United States',
            flag: 'us',
          },
          ...held_events.map((event_id) => {
            if (registration.event_ids.includes(event_id)) {
              return { title: event_id, icon: true }
            } else {
              return ''
            }
          }),
          {
            title: registration.event_ids.length,
          },
        ]
      })
      setRegistrationList(rows)
      setLoading(false)
    })
  }, [competition_id])
  return (
    <div className={styles.list}>
      <NonInteractiveTable
        rows={registrationList}
        header={header}
        footer={footer}
        loading={loading}
      />
    </div>
  )
}

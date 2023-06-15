import { NonInteractiveTable } from '@thewca/wca-components'
import React, { useEffect, useMemo, useState } from 'react'
import { useParams } from 'react-router-dom'
import getCompetitionInfo from '../../../api/competition/get/get_competition_info'
import { getConfirmedRegistrations } from '../../../api/registration/get/get_registrations'
import getCompetitorInfo from '../../../api/user/get/get_user_info'
import styles from './list.module.scss'

export default function RegistrationList() {
  const { competition_id } = useParams()
  const [loading, setLoading] = useState(true)
  const [registrations, setRegistrations] = useState([])
  const [heldEvents, setHeldEvents] = useState([])

  // Fetch data
  useEffect(() => {
    getCompetitionInfo(competition_id).then((competitionInfo) => {
      setHeldEvents(competitionInfo.event_ids)
    })
  }, [competition_id])

  useEffect(() => {
    getConfirmedRegistrations(competition_id).then(async (registrations) => {
      const regList = []
      for (const registration of registrations) {
        registration.user = (
          await getCompetitorInfo(registration.competitor_id)
        ).user
        regList.push(registration)
      }
      setRegistrations(regList)
      setLoading(false)
    })
  }, [competition_id])

  const header = [
    { text: 'Name' },
    { text: 'Citizen of' },
    ...heldEvents.map((event_id) => ({ text: event_id, cubingIcon: true })),
    { text: 'Total' },
  ]
  const footer = useMemo(() => {
    let newcomers = 0
    let returners = 0
    let total = 0
    const countrySet = new Set()
    // We have to use a Map instead of an object to preserve event order
    const eventCounts = heldEvents.reduce((counts, eventId) => {
      counts.set(eventId, 0)
      return counts
    }, new Map())
    registrations.forEach((registration) => {
      if (registration.user.wca_id === null) {
        newcomers++
      } else {
        returners++
      }
      countrySet.add(registration.user.country.iso2)
      total += registration.event_ids.length
      heldEvents.forEach((event_id) => {
        if (registration.event_ids.includes(event_id)) {
          eventCounts.set(event_id, eventCounts.get(event_id) + 1)
        }
      })
    })
    return [
      // Potential grammar issues will be fixed when we introduce I18n
      `${newcomers} First-timers + ${returners} Returners = ${
        newcomers + returners
      } People`,
      `${countrySet.size} Countries`,
      ...eventCounts.values(),
      total,
      '',
    ]
  }, [registrations, heldEvents])
  const registrationList = useMemo(
    () =>
      registrations.map((registration) => {
        let profile_link = null
        if (registration.user.wca_id !== null) {
          profile_link = `https://www.worldcubeassociation.org/persons/${registration.user.wca_id}`
        }
        return [
          {
            text: registration.user.name,
            link: profile_link,
          },
          {
            text: registration.user.country.name,
            flag: registration.user.country.iso2,
          },
          ...heldEvents.map((event_id) => {
            if (registration.event_ids.includes(event_id)) {
              return { text: event_id, cubingIcon: true }
            }
            return ''
          }),
          {
            text: registration.event_ids.length,
          },
        ]
      }),
    [registrations, heldEvents]
  )
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

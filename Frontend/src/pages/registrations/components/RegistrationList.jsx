import { NonInteractiveTable } from '@thewca/wca-components'
import React, { useEffect, useMemo, useState } from 'react'
import { useParams } from 'react-router-dom'
import { useHeldEvents } from '../../../api/helper/hooks/use_competition_info'
import { getConfirmedRegistrations } from '../../../api/registration/get/get_registrations'
import getCompetitorInfo from '../../../api/user/get/get_user_info'
import LoadingMessage from '../../../ui/messages/loadingMessage'
import styles from './list.module.scss'

export default function RegistrationList() {
  const { competition_id } = useParams()
  const [isLoading, setIsLoading] = useState(true)
  const [registrations, setRegistrations] = useState([])
  // Fetch data
  const { isLoading: eventsLoading, heldEvents } = useHeldEvents(competition_id)

  useEffect(() => {
    getConfirmedRegistrations(competition_id).then(async (registrations) => {
      const regList = []
      for (const registration of registrations) {
        registration.user = (await getCompetitorInfo(registration.user_id)).user
        regList.push(registration)
      }
      setRegistrations(regList)
      setIsLoading(false)
    })
  }, [competition_id])

  const header = [
    { text: 'Name' },
    { text: 'Citizen of' },
    ...heldEvents.map((event_id) => ({ text: event_id, cubingIcon: true })),
    { text: 'Total' },
  ]
  const footer = useMemo(() => {
    // We have to use a Map instead of an object to preserve event order
    const eventCounts = heldEvents.reduce((counts, eventId) => {
      counts.set(eventId, 0)
      return counts
    }, new Map())
    const { newcomers, totalEvents, countrySet } = registrations.reduce(
      (info, registration) => {
        if (registration.user.wca_id === null) {
          info.newcomers++
        }
        info.countrySet.add(registration.user.country.iso2)
        info.totalEvents += registration.event_ids.length
        heldEvents.forEach((event_id) => {
          if (registration.event_ids.includes(event_id)) {
            eventCounts.set(event_id, eventCounts.get(event_id) + 1)
          }
        })
        return info
      },
      { newcomers: 0, totalEvents: 0, countrySet: new Set() }
    )
    return [
      // Potential grammar issues will be fixed when we introduce I18n
      `${newcomers} First-timers + ${
        registrations.length - newcomers
      } Returners = ${registrations.length} People`,
      `${countrySet.size} Countries`,
      ...eventCounts.values(),
      totalEvents,
    ]
  }, [registrations, heldEvents])
  const registrationList = useMemo(
    () =>
      registrations.map((registration) => {
        const profileLink = registration.user.wca_id
          ? `https://www.worldcubeassociation.org/persons/${registration.user.wca_id}`
          : null
        return [
          {
            text: registration.user.name,
            link: profileLink,
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
      {isLoading || eventsLoading ? (
        <LoadingMessage />
      ) : (
        <NonInteractiveTable
          rows={registrationList}
          header={header}
          footer={footer}
        />
      )}
    </div>
  )
}

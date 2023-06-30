import { useQuery } from '@tanstack/react-query'
import { NonInteractiveTable } from '@thewca/wca-components'
import React, { useContext, useMemo } from 'react'
import { CompetitionContext } from '../../../api/helper/context/competition_context'
import { getConfirmedRegistrations } from '../../../api/registration/get/get_registrations'
import LoadingMessage from '../../../ui/messages/loadingMessage'
import styles from './list.module.scss'

export default function RegistrationList() {
  // Fetch data
  const { competitionInfo } = useContext(CompetitionContext)

  const { isLoading, data: registrations } = useQuery({
    queryKey: ['registrations', competitionInfo.id],
    queryFn: () => getConfirmedRegistrations(competitionInfo.id),
  })

  const header = [
    { text: 'Name' },
    { text: 'Citizen of' },
    ...competitionInfo.event_ids.map((event_id) => ({
      text: event_id,
      cubingIcon: true,
    })),
    { text: 'Total' },
  ]
  const footer = useMemo(() => {
    if (registrations) {
      // We have to use a Map instead of an object to preserve event order
      const eventCounts = competitionInfo.event_ids.reduce(
        (counts, eventId) => {
          counts.set(eventId, 0)
          return counts
        },
        new Map()
      )
      const { newcomers, totalEvents, countrySet } = registrations.reduce(
        (info, registration) => {
          if (registration.user.wca_id === null) {
            info.newcomers++
          }
          info.countrySet.add(registration.user.country.iso2)
          info.totalEvents += registration.event_ids.length
          competitionInfo.event_ids.forEach((event_id) => {
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
    }
    return []
  }, [registrations, competitionInfo.event_ids])
  const registrationList = useMemo(
    () =>
      registrations?.map((registration) => {
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
          ...competitionInfo.event_ids.map((event_id) => {
            if (registration.event_ids.includes(event_id)) {
              return { text: event_id, cubingIcon: true }
            }
            return ''
          }),
          {
            text: registration.event_ids.length,
          },
        ]
      }) ?? [],
    [registrations, competitionInfo.event_ids]
  )
  return (
    <div className={styles.list}>
      {isLoading ? (
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

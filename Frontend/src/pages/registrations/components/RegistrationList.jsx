import { NonInteractiveTable } from '@thewca/wca-components'
import React, { useEffect, useState } from 'react'
import { useParams } from 'react-router-dom'
import getCompetitionInfo from '../../../api/competition/get/get_competition_info'
import { getConfirmedRegistrations } from '../../../api/registration/get/get_registrations'
import getCompetitorInfo from '../../../api/user/get/get_user_info'
import styles from './list.module.scss'

export default function RegistrationList() {
  const { competition_id } = useParams()
  const [registrationList, setRegistrationList] = useState([])
  const [heldEvents, setHeldEvents] = useState([])
  const [header, setHeader] = useState([])
  const [footer, setFooter] = useState([])
  const [loading, setLoading] = useState(true)
  useEffect(() => {
    getCompetitionInfo(competition_id).then((competitionInfo) => {
      setHeldEvents(competitionInfo.event_ids)
      setHeader([
        { text: 'Name' },
        { text: 'Citizen of' },
        ...competitionInfo.event_ids.map((event_id) => {
          return { text: event_id, cubingIcon: true }
        }),
        { text: 'Total' },
      ])
    })
  }, [competition_id])
  useEffect(() => {
    getConfirmedRegistrations(competition_id).then(async (registrations) => {
      let newcomers = 0
      let returners = 0
      let total = 0
      const countrySet = new Set()
      // We have to use a Map instead of an object to preserve event order
      const eventCounts = heldEvents.reduce((counts, eventId) => {
        counts.set(eventId, 0)
        return counts
      }, new Map())
      const rows = registrations.map(async (registration) => {
        let profile_link = null
        const competitorInfo = await getCompetitorInfo(
          registration.competitor_id
        )
        if (competitorInfo.user.wca_id === null) {
          newcomers++
        } else {
          returners++
          profile_link = `https://www.worldcubeassociation.org/persons/${competitorInfo.user.wca_id}`
        }
        countrySet.add(competitorInfo.user.country.iso2)
        total += registration.event_ids.length
        return [
          {
            text: competitorInfo.user.name,
            link: profile_link,
          },
          {
            text: competitorInfo.user.country.name,
            flag: competitorInfo.user.country.iso2,
          },
          ...heldEvents.map((event_id) => {
            if (registration.event_ids.includes(event_id)) {
              eventCounts.set(event_id, eventCounts.get(event_id) + 1)
              return { text: event_id, cubingIcon: true }
            }
            return ''
          }),
          {
            text: registration.event_ids.length,
          },
        ]
      })
      setRegistrationList(await Promise.all(rows))
      setFooter([
        // Potential grammar issues will be fixed when we introduce I18n
        `${newcomers} first-timers + ${returners} Returners = ${
          newcomers + returners
        } People`,
        `${countrySet.size} Countries`,
        ...eventCounts.values(),
        total,
        '',
      ])
      setLoading(false)
    })
  }, [competition_id, heldEvents])
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

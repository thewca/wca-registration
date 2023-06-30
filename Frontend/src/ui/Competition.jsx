import { useQuery } from '@tanstack/react-query'
import { CubingIcon, UiIcon } from '@thewca/wca-components'
import React from 'react'
import { useParams } from 'react-router-dom'
import { Button, Image } from 'semantic-ui-react'
import getCompetitionInfo from '../api/competition/get/get_competition_info'
import { CompetitionContext } from '../api/helper/context/competition_context'
import styles from './competition.module.scss'
import LoadingMessage from './messages/loadingMessage'

export default function Competition({ children }) {
  const { competition_id } = useParams()
  const { isLoading, data: competitionInfo } = useQuery({
    queryKey: [competition_id],
    queryFn: () => getCompetitionInfo(competition_id),
  })
  return (
    <CompetitionContext.Provider
      value={{ competitionInfo: competitionInfo ?? {} }}
    >
      {isLoading ? (
        <LoadingMessage />
      ) : (
        <>
          <div className={styles.competitionInfo}>
            <div className={styles.header}>
              <div className={styles.infoLeft}>
                <div className={styles.competitionName}>
                  <UiIcon name="bookmark ouline" /> {competitionInfo.name} |{' '}
                  <span className={styles.open}>Open</span>
                </div>
                <div className={styles.location}>
                  <UiIcon name="pin" /> {competitionInfo.venue_address}
                </div>
                <div className={styles.date}>
                  {new Date(competitionInfo.start_date).toDateString()},{' '}
                  <a href="https://calendar.google.com">
                    Add to Google Calendar
                  </a>
                </div>
                <div className={styles.announcement}>
                  *Insert Potential organizer announcement or memo for users to
                  view before hitting register*
                </div>
                <Button className={styles.registerButton}>Register</Button>
                <span className={styles.fee}>Registration Fee of $$$</span>
              </div>
              <div className={styles.infoRight}>
                <Image href={competitionInfo.url} className={styles.image} />
              </div>
            </div>
            <div className={styles.eventList}>
              <div>
                <span className={styles.eventHeader}>Events:</span>
                {competitionInfo.event_ids.map((event) => (
                  <span key={`event-header-${event}`} className={styles.event}>
                    <CubingIcon event={event} selected={true} />
                  </span>
                ))}
              </div>
              <div>
                <span className={styles.eventHeader}>Main Event:</span>
                <span className={styles.event}>
                  <CubingIcon
                    event={competitionInfo.event_ids[0]}
                    selected={true}
                  />
                </span>
              </div>
            </div>
          </div>
          {children}
        </>
      )}
    </CompetitionContext.Provider>
  )
}

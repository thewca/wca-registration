import { UiIcon } from '@thewca/wca-components'
import { marked } from 'marked'
import moment from 'moment'
import React, { useContext, useState } from 'react'
import { Button } from 'semantic-ui-react'
import { CompetitionContext } from '../../api/helper/context/competition_context'
import RegistrationRequirements from '../register/components/RegistrationRequirements'
import styles from './index.module.scss'

export default function HomePage() {
  const { competitionInfo } = useContext(CompetitionContext)
  const [ showAllRequirements, setShowAllRequirements ] = useState(false)
  return (
    <div className={styles.homeContainer}>
      <div className={styles.requirements}>
        <div>Registration Requirements:</div>
        <div>[INSERT ORGANIZER MESSAGE REGARDING REQUIREMENTS]</div>
        {showAllRequirements && <RegistrationRequirements />}
        <div>
          <Button onClick={() => setShowAllRequirements(!showAllRequirements)}>
            View All
          </Button>
        </div>
      </div>
      {competitionInfo.information && (
        <div className={styles.information}>
          <div className={styles.informationHeader}>Information:</div>
          <div
            className={styles.informationText}
            dangerouslySetInnerHTML={{
              __html: marked(competitionInfo.information),
            }}
          />
        </div>
      )}
      <div className={styles.registrationPeriod}>
        <div className={styles.registrationHeader}>Registration Period:</div>
        <div className={styles.registrationPeriodText}>
          {new Date(competitionInfo.registration_open) < new Date()
            ? `Registration opened ${moment(
                competitionInfo.registration_open
              ).calendar()} and will close ${moment(
                competitionInfo.registration_close
              ).format('ll')}`
            : `Registration will open ${moment(
                competitionInfo.registration_open
              ).calendar()}`}
        </div>
      </div>
      <div className={styles.details}>
        <div>
          <span className={styles.detailHeader}>Date: </span>
          {moment(competitionInfo.start_date).format('ll')}
        </div>
        <div>
          <span className={styles.detailHeader}>Start Time: </span>
          XX:XX PM
        </div>
        <div>
          <span className={styles.detailHeader}>City: </span>
          {competitionInfo.city}, {competitionInfo.country_iso2}
        </div>
        <div>
          <span className={styles.detailHeader}>Venue: </span>
          <span
            dangerouslySetInnerHTML={{ __html: marked(competitionInfo.venue) }}
          />
          <ul>
            <li>
              <span className={styles.detailHeader}>Address: </span>
              {competitionInfo.venue_address}
            </li>
            {competitionInfo.venue_details && (
              <li>
                <span className={styles.detailHeader}>Details: </span>
                {competitionInfo.venue_details}
              </li>
            )}
          </ul>
        </div>
        <div>
          <span className={styles.detailHeader}>Competitor Limit: </span>
          {competitionInfo.competitor_limit}
        </div>
        <div>
          <span className={styles.detailHeader}>Contact: </span>
          {competitionInfo.contact ? (
            <span
              dangerouslySetInnerHTML={{
                __html: marked(competitionInfo.contact),
              }}
            />
          ) : (
            <a
              href={`https://www.worldcubeassociation.org/contact/website?competitionId=${competitionInfo.id}`}
              className={styles.delegateLink}
            >
              Organization Team
            </a>
          )}
        </div>
        <div>
          <span className={styles.detailHeader}>Organizers: </span>
          {competitionInfo.organizers.map((organizer) => (
            <a
              key={`competition-organizer-${organizer.id}`}
              href={`mailto:${organizer.email}`}
              className={styles.delegateLink}
            >
              {organizer.name}
            </a>
          ))}
        </div>
        <div>
          <span className={styles.detailHeader}>Delegates: </span>
          {competitionInfo.delegates.map((delegate) => (
            <a
              key={`competition-organizer-${delegate.id}`}
              href={`mailto:${delegate.email}`}
              className={styles.delegateLink}
            >
              {delegate.name}
            </a>
          ))}
        </div>
        <div>
          <UiIcon name="print" /> Download all of the competitions details as a
          PDF{' '}
          <a
            href={`https://www.worldcubeassociation.org/competitions/${competitionInfo.id}.pdf`}
          >
            here
          </a>
        </div>
      </div>
      <div className={styles.bookmarked}>
        The Competition has been bookmarked{' '}
        {competitionInfo.number_of_bookmarks} times
      </div>
    </div>
  )
}

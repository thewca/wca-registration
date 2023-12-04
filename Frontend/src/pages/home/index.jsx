import { UiIcon } from '@thewca/wca-components'
import { marked } from 'marked'
import moment from 'moment'
import React, { useContext } from 'react'
import { Container, Header, Segment } from 'semantic-ui-react'
import { CompetitionContext } from '../../api/helper/context/competition_context'
import RegistrationRequirements from '../register/components/RegistrationRequirements'
import styles from './index.module.scss'
import InfoGrid from './InfoGrid'

export default function HomePage() {
  const { competitionInfo } = useContext(CompetitionContext)

  return (
    <Container>
      <div>
        <RegistrationRequirements />
      </div>

      {competitionInfo.information && (
        <div>
          <Header as="h3">Information:</Header>
          <div
            className={styles.information}
            dangerouslySetInnerHTML={{
              __html: marked(competitionInfo.information),
            }}
          />
        </div>
      )}

      <Header as="h3">
        Registration Period:
        <Header.Subheader>
          {new Date(competitionInfo.registration_open) < new Date()
            ? `Registration opened ${moment(
                competitionInfo.registration_open
              ).calendar()} and will close ${moment(
                competitionInfo.registration_close
              ).format('ll')}`
            : `Registration will open ${moment(
                competitionInfo.registration_open
              ).calendar()}`}
        </Header.Subheader>
      </Header>

      <Segment padded attached>
        <InfoGrid competitionInfo={competitionInfo} />

        <Header className={styles.informationHeader}>
          <UiIcon name="print" />
          <Header.Content>
            Download all of the competitions details as a PDF{' '}
            <a
              href={`https://www.worldcubeassociation.org/competitions/${competitionInfo.id}.pdf`}
            >
              here
            </a>
          </Header.Content>
        </Header>
      </Segment>

      <Header attached="bottom" textAlign="center" as="h2">
        The Competition has been bookmarked{' '}
        {competitionInfo.number_of_bookmarks} times
      </Header>
    </Container>
  )
}

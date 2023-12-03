import { marked } from 'marked'
import moment from 'moment'
import React, { useContext } from 'react'
import {Container, Header} from 'semantic-ui-react'
import { CompetitionContext } from '../../api/helper/context/competition_context'
import styles from './index.module.scss'

export default function HomePage() {
  const { competitionInfo } = useContext(CompetitionContext)
  return (
    <Container>
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
    </Container>
  )
}

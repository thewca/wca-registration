import { UiIcon } from '@thewca/wca-components'
import { marked } from 'marked'
import moment from 'moment'
import React, { useContext } from 'react'
import { Container, Grid, Header, Segment } from 'semantic-ui-react'
import { CompetitionContext } from '../../api/helper/context/competition_context'
import RegistrationRequirements from '../register/components/RegistrationRequirements'
import styles from './index.module.scss'

export default function HomePage() {
  const { competitionInfo } = useContext(CompetitionContext);
  
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

function InfoGrid({ competitionInfo }) {
  return (
    <Grid columns={2}>
      <InfoGridRow>
          <InfoGridHeader>Date</InfoGridHeader>
          <InfoGridHeader>
            {competitionInfo.start_date === competitionInfo.end_date
              ? `${moment(competitionInfo.start_date).format('ll')}`
              : `${moment(competitionInfo.start_date).format(
                  'll'
                )} to ${moment(competitionInfo.end_date).format('ll')}`}
          </InfoGridHeader>
      </InfoGridRow>

      <InfoGridRow>
          <InfoGridHeader>City</InfoGridHeader>
          <InfoGridHeader>
            {competitionInfo.city}, {competitionInfo.country_iso2}
          </InfoGridHeader>
      </InfoGridRow>

      <InfoGridRow>
        <InfoGridHeader>Venue</InfoGridHeader>
        <InfoGridHeader>
          <p
            dangerouslySetInnerHTML={{
              __html: marked(competitionInfo.venue),
            }}
          />
        </InfoGridHeader>
      </InfoGridRow>

      <InfoGridRow>
        <InfoGridHeader color="grey">
          Address
        </InfoGridHeader>
        <InfoGridHeader color="grey">
          {competitionInfo.venue_address}
        </InfoGridHeader>
      </InfoGridRow>

      {competitionInfo.venue_details && (
        <InfoGridRow>
          <InfoGridHeader color="grey">
            Details
          </InfoGridHeader>
          <InfoGridHeader color="grey">
            {competitionInfo.venue_details}
          </InfoGridHeader>
        </InfoGridRow>
      )}

      <InfoGridRow>
        <InfoGridHeader>
          Competitor Limit
        </InfoGridHeader>
        <InfoGridHeader>
          {competitionInfo.competitor_limit ?? "None"}
        </InfoGridHeader>
      </InfoGridRow>

      <InfoGridRow>
        <InfoGridHeader>Contact</InfoGridHeader>
        <InfoGridHeader>
          {competitionInfo.contact ? (
            <span
              dangerouslySetInnerHTML={{
                __html: marked(competitionInfo.contact),
              }}
            />
          ) : (
            <a
              href={`https://www.worldcubeassociation.org/contact/website?competitionId=${competitionInfo.id}`}
            >
              Organization Team
            </a>
          )}
        </InfoGridHeader>
      </InfoGridRow>

      <InfoGridRow>
        <InfoGridHeader>Organizers</InfoGridHeader>
        <InfoGridHeader>
          <PersonList people={competitionInfo.organizers} />
        </InfoGridHeader>
      </InfoGridRow>

      <InfoGridRow>
        <InfoGridHeader>Delegates</InfoGridHeader>
        <InfoGridHeader>
          <PersonList people={competitionInfo.delegates} />
        </InfoGridHeader>
      </InfoGridRow>
    </Grid>
  )
}

function InfoGridRow({ children }) {
  return (
    <Grid.Row>
      <Grid.Column computer={3} tablet={5} mobile={5}>
        {children[0]}
      </Grid.Column>
      <Grid.Column computer={12} tablet={10} mobile={10}>
        {children[1]}
      </Grid.Column>
    </Grid.Row>
  )
}

function InfoGridHeader({ color, children }) {
  return (
    <Header className={styles.informationHeader} color={color}>
      {children}
    </Header>
  )
}

function PersonList({ people }) {
  return (
    people.map((person, index) => (
      <>
        {index > 0 && ", "}
        <a
          key={person.id}
          href={`${process.env.WCA_URL}/persons/${person.wca_id}`}
        >
          {person.name}
        </a>
      </>
    ))
  )
}

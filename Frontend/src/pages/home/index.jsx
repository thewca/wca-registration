import { UiIcon } from '@thewca/wca-components'
import { marked } from 'marked'
import moment from 'moment'
import React, { useContext } from 'react'
import { Container, Grid, Header, Segment } from 'semantic-ui-react'
import { CompetitionContext } from '../../api/helper/context/competition_context'
import RegistrationRequirements from '../register/components/RegistrationRequirements'

export default function HomePage() {
  const { competitionInfo } = useContext(CompetitionContext)
  return (
    <Container>
      <div>
        <RegistrationRequirements />
      </div>
      {competitionInfo.information && (
        <>
          <Header as="h3">Information:</Header>
          <div
            dangerouslySetInnerHTML={{
              __html: marked(competitionInfo.information),
            }}
          />
        </>
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
        <Grid>
          <Grid.Column width={3}>
            <Header>Date</Header>
            <Header>City</Header>
            <Header>Venue</Header>
            <Header color="grey">Address</Header>
            {competitionInfo.venue_details && (
              <Header color="grey">Details</Header>
            )}
            <Header>Competitor Limit</Header>
            <Header>Contact</Header>
            <Header>Organizers</Header>
            <Header>Delegates</Header>
          </Grid.Column>
          <Grid.Column width={12}>
            <Header>
              {competitionInfo.start_date === competitionInfo.end_date
                ? `${moment(competitionInfo.start_date).format('ll')}`
                : `${moment(competitionInfo.start_date).format(
                    'll'
                  )} to ${moment(competitionInfo.end_date).format('ll')}`}
            </Header>
            <Header>
              {competitionInfo.city}, {competitionInfo.country_iso2}
            </Header>
            <Header>
              <p
                dangerouslySetInnerHTML={{
                  __html: marked(competitionInfo.venue),
                }}
              />
            </Header>
            <Header color="grey">{competitionInfo.venue_address}</Header>
            {competitionInfo.venue_details && (
              <Header color="grey">{competitionInfo.venue_details}</Header>
            )}
            <Header>{competitionInfo.competitor_limit}</Header>
            <Header>
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
            </Header>
            <Header>
              {competitionInfo.organizers.map((organizer, index) => (
                <a
                  key={`competition-organizer-${organizer.id}`}
                  href={`${process.env.WCA_URL}/persons/${organizer.wca_id}`}
                >
                  {organizer.name}
                  {index !== competitionInfo.organizers.length - 1 ? ', ' : ''}
                </a>
              ))}
            </Header>
            <Header>
              {competitionInfo.delegates.map((delegate, index) => (
                <a
                  key={`competition-organizer-${delegate.id}`}
                  href={`${process.env.WCA_URL}/persons/${delegate.wca_id}`}
                >
                  {delegate.name}
                  {index !== competitionInfo.delegates.length - 1 ? ', ' : ''}
                </a>
              ))}
            </Header>
          </Grid.Column>
        </Grid>
        <Header>
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

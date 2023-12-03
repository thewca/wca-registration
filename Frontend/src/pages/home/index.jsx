import { UiIcon } from '@thewca/wca-components'
import { marked } from 'marked'
import moment from 'moment'
import React, { useContext } from 'react'
import {Container, Flag, Grid, Header, Label, List, Segment} from 'semantic-ui-react'
import { CompetitionContext } from '../../api/helper/context/competition_context'
import RegistrationRequirements from '../register/components/RegistrationRequirements'
import styles from './index.module.scss'

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
        <List divided relaxed size="huge">
          <List.Item>
            <List.Content floated="right">
              <a
                  href={`https://calendar.google.com/calendar/render?action=TEMPLATE&text=${
                      competitionInfo.id
                  }&dates=${moment(competitionInfo.start_date).format(
                      'YYYYMMDD'
                  )}/${moment(competitionInfo.end_date).format(
                      'YYYYMMDD'
                  )}&location=${competitionInfo.venue_address}`}
                  target="_blank"
              >
                <UiIcon name="calendar plus" />
              </a>
            </List.Content>
            <List.Icon name="calendar alternate" />
            <List.Content>
              {competitionInfo.start_date === competitionInfo.end_date
                  ? `${moment(competitionInfo.start_date).format('ll')}`
                  : `${moment(competitionInfo.start_date).format(
                      'll'
                  )} to ${moment(competitionInfo.end_date).format('ll')}`}
            </List.Content>
          </List.Item>
          <List.Item>
            <List.Icon name="globe" />
            <List.Content>
              {competitionInfo.city}
              <Flag name={competitionInfo.country_iso2} />
            </List.Content>
          </List.Item>
          <List.Item>
            <List.Icon name="home" />
            <List.Content>
              <List.Header>
                <p
                    dangerouslySetInnerHTML={{
                      __html: marked(competitionInfo.venue),
                    }}
                />
              </List.Header>
              <List.List>
                <List.Item>
                  <List.Content floated="right">
                    <UiIcon name="google" />
                  </List.Content>
                  <List.Icon name="map" />
                  <List.Content>
                    {competitionInfo.venue_address}
                  </List.Content>
                </List.Item>
                {competitionInfo.venue_details && (
                    <List.Item>
                      <List.Icon name="map signs"></List.Icon>
                      <List.Content>
                        {competitionInfo.venue_details}
                      </List.Content>
                    </List.Item>
                )}
              </List.List>
            </List.Content>
          </List.Item>
          <List.Item>
            <List.Icon name="users" />
            <List.Content>
              {competitionInfo.competitor_limit}
            </List.Content>
          </List.Item>
          <List.Item>
            <List.Icon name="mail" />
            <List.Content>
              <List.Header>
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
              </List.Header>
              <List.List>
                <List.Item>
                  <List.Icon name="user circle" />
                  <List.Content>
                    <List.Header>Organizers</List.Header>
                    <List.Description>
                      {competitionInfo.organizers.map((organizer, index) => (
                          <a
                              key={`competition-organizer-${organizer.id}`}
                              href={`${process.env.WCA_URL}/persons/${organizer.wca_id}`}
                          >
                            {organizer.name}
                            {index !== competitionInfo.organizers.length - 1 ? ', ' : ''}
                          </a>
                      ))}
                    </List.Description>
                  </List.Content>
                </List.Item>
                <List.Item>
                  <List.Icon name="user secret" />
                  <List.Content>
                    <List.Header>Delegates</List.Header>
                    <List.Description>
                      {competitionInfo.delegates.map((delegate, index) => (
                          <a
                              key={`competition-organizer-${delegate.id}`}
                              href={`${process.env.WCA_URL}/persons/${delegate.wca_id}`}
                          >
                            {delegate.name}
                            {index !== competitionInfo.delegates.length - 1 ? ', ' : ''}
                          </a>
                      ))}
                    </List.Description>
                  </List.Content>
                </List.Item>
              </List.List>
            </List.Content>
          </List.Item>
          <List.Item>
            <List.Icon name="print" />
            <List.Content>
              <List.Header>Download all of the competitions details</List.Header>
              <List.List>
                <List.Item>
                  <List.Icon name="file pdf" />
                  <List.Content>
                    As a{' '}
                    <a
                        href={`https://www.worldcubeassociation.org/competitions/${competitionInfo.id}.pdf`}
                    >
                      PDF
                    </a>
                  </List.Content>
                </List.Item>
              </List.List>
            </List.Content>
          </List.Item>
          <List.Item>
            <List.Icon name="bookmark" />
            <List.Content>
              <List.Header>Bookmark this competition</List.Header>
              <List.Description>
                The Competition has been bookmarked{' '}
                {competitionInfo.number_of_bookmarks} times
              </List.Description>
            </List.Content>
          </List.Item>
        </List>
      </Segment>
    </Container>
  )
}

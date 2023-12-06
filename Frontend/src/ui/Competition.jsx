import { useQuery } from '@tanstack/react-query'
import { CubingIcon, UiIcon } from '@thewca/wca-components'
import { marked } from 'marked'
import moment from 'moment'
import React, { useContext, useEffect, useMemo, useState } from 'react'
import { useParams } from 'react-router-dom'
import {
  Container,
  Flag,
  Header,
  Image,
  List,
  Segment,
} from 'semantic-ui-react'
import getCompetitionInfo from '../api/competition/get/get_competition_info'
import {
  bookmarkCompetition,
  unbookmarkCompetition,
} from '../api/competition/post/bookmark_competition'
import { CompetitionContext } from '../api/helper/context/competition_context'
import { UserContext } from '../api/helper/context/user_context'
import {
  competitionContactFormRoute,
  competitionsPDFRoute,
  userProfileRoute,
} from '../api/helper/routes'
import { getBookmarkedCompetitions } from '../api/user/get/get_bookmarked_competitions'
import logo from '../static/wca2020.svg'
import { setMessage } from './events/messages'
import LoadingMessage from './messages/loadingMessage'

export default function Competition({ children }) {
  const { competition_id } = useParams()

  const { user } = useContext(UserContext)

  const { isLoading, data: competitionInfo } = useQuery({
    queryKey: [competition_id],
    queryFn: () => getCompetitionInfo(competition_id),
  })

  const { data: bookmarkedCompetitions } = useQuery({
    queryKey: [user.id, 'bookmarks'],
    queryFn: () => getBookmarkedCompetitions(),
  })

  const [competitionIsBookmarked, setIsCompetitionIsBookmarked] =
    useState(false)

  useEffect(() => {
    setIsCompetitionIsBookmarked(
      (bookmarkedCompetitions ?? []).includes(competitionInfo?.id)
    )
  }, [bookmarkedCompetitions, competitionInfo?.id])

  // Hack before we have an image Icon field in the DB
  const src = useMemo(() => {
    if (competitionInfo) {
      const div = document.createElement('DIV')
      div.innerHTML = marked(competitionInfo.information)
      return div.querySelector('img')?.src ?? logo
    }
    return ''
  }, [competitionInfo])

  return (
    <CompetitionContext.Provider
      value={{ competitionInfo: competitionInfo ?? {} }}
    >
      {isLoading ? (
        <LoadingMessage />
      ) : (
        <>
          <Container>
            <Header as="h1" textAlign="center" attached="top">
              <Image src={src} centered floated="right" />
              {competitionInfo.name}
              <Header.Subheader>
                <List horizontal>
                  {competitionInfo.event_ids.map((event) => (
                    <List.Item key={event}>
                      <CubingIcon
                        event={event}
                        size={
                          event === competitionInfo.main_event_id ? '2x' : '1x'
                        }
                        selected
                      />
                    </List.Item>
                  ))}
                </List>
              </Header.Subheader>
            </Header>
            <Segment attached>
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
                    <Flag name={competitionInfo.country_iso2.toLowerCase()} />
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
                          <a
                            href={`https://google.com/maps/place/${competitionInfo.latitude_degrees},${competitionInfo.longitude_degrees}`}
                            target="_blank"
                          >
                            <UiIcon name="google" />
                          </a>
                        </List.Content>
                        <List.Icon name="map" />
                        <List.Content>
                          {competitionInfo.venue_address}
                        </List.Content>
                      </List.Item>
                      {competitionInfo.venue_details && (
                        <List.Item>
                          <List.Icon name="map signs" />
                          <List.Content>
                            {competitionInfo.venue_details}
                          </List.Content>
                        </List.Item>
                      )}
                    </List.List>
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
                          href={competitionContactFormRoute(competitionInfo.id)}
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
                            {competitionInfo.organizers.map(
                              (organizer, index) => (
                                <a
                                  key={`competition-organizer-${organizer.id}`}
                                  href={userProfileRoute(organizer.wca_id)}
                                >
                                  {organizer.name}
                                  {index !==
                                  competitionInfo.organizers.length - 1
                                    ? ', '
                                    : ''}
                                </a>
                              )
                            )}
                          </List.Description>
                        </List.Content>
                      </List.Item>
                      <List.Item>
                        <List.Icon name="user secret" />
                        <List.Content>
                          <List.Header>Delegates</List.Header>
                          <List.Description>
                            {competitionInfo.delegates.map(
                              (delegate, index) => (
                                <a
                                  key={`competition-organizer-${delegate.id}`}
                                  href={userProfileRoute(delegate.wca_id)}
                                >
                                  {delegate.name}
                                  {index !==
                                  competitionInfo.delegates.length - 1
                                    ? ', '
                                    : ''}
                                </a>
                              )
                            )}
                          </List.Description>
                        </List.Content>
                      </List.Item>
                    </List.List>
                  </List.Content>
                </List.Item>
              </List>
            </Segment>
          </Container>
          {children}
          <Segment padded attached secondary>
            <List divided relaxed>
              <List.Item>
                <List.Icon name="print" />
                <List.Content>
                  <List.Header>
                    Download all of the competitions details
                  </List.Header>
                  <List.List>
                    <List.Item>
                      <List.Icon name="file pdf" />
                      <List.Content>
                        As a{' '}
                        <a href={competitionsPDFRoute(competitionInfo.id)}>
                          PDF
                        </a>
                      </List.Content>
                    </List.Item>
                  </List.List>
                </List.Content>
              </List.Item>
              <List.Item>
                <List.Icon
                  link
                  onClick={() => {
                    if (competitionIsBookmarked) {
                      unbookmarkCompetition(competitionInfo.id)
                      setIsCompetitionIsBookmarked(false)
                      setMessage('Unbookmarked this competition.', 'basic')
                    } else {
                      bookmarkCompetition(competitionInfo.id)
                      setIsCompetitionIsBookmarked(true)
                      setMessage(
                        'You bookmarked this competition. You will get an email 24h before Registration Opens.',
                        'positive'
                      )
                    }
                  }}
                  name="bookmark"
                  color={competitionIsBookmarked ? 'black' : 'grey'}
                />
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
        </>
      )}
    </CompetitionContext.Provider>
  )
}

import * as currencies from '@dinero.js/currencies'
import { useQuery } from '@tanstack/react-query'
import { CubingIcon, UiIcon } from '@thewca/wca-components'
import { dinero, toDecimal } from 'dinero.js'
import { marked } from 'marked'
import moment from 'moment'
import React, { useContext, useMemo } from 'react'
import { useNavigate, useParams } from 'react-router-dom'
import {
  Button,
  Container,
  Flag,
  Header,
  Image,
  Label,
  List,
  Message,
  Segment,
} from 'semantic-ui-react'
import getCompetitionInfo from '../api/competition/get/get_competition_info'
import { CompetitionContext } from '../api/helper/context/competition_context'
import { UserContext } from '../api/helper/context/user_context'
import { BASE_ROUTE } from '../routes'
import logo from '../static/wca2020.svg'
import LoadingMessage from './messages/loadingMessage'

export default function Competition({ children }) {
  const { competition_id } = useParams()
  const navigate = useNavigate()
  const { user } = useContext(UserContext)

  const { isLoading, data: competitionInfo } = useQuery({
    queryKey: [competition_id],
    queryFn: () => getCompetitionInfo(competition_id),
  })

  // Hack before we have an image Icon field in the DB
  const src = useMemo(() => {
    if (competitionInfo) {
      const div = document.createElement('DIV')
      div.innerHTML = marked(competitionInfo.information)
      return div.querySelector('img')?.src ?? logo
    }
    return ''
  }, [competitionInfo])

  const regOpenDate = new Date(competitionInfo?.registration_open)
  const regClosingDate = new Date(competitionInfo?.registration_close)

  const now = Date.now();

  const isRegistrationOpen = regOpenDate <= now && regClosingDate >= now;

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
                            size={event === competitionInfo.main_event_id ? '2x' : '1x'}
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
              </List>
            </Segment>

            <Segment padded attached raised>
              <Message warning>
                *Insert Potential organizer announcement or memo for users
                to view before hitting register*
              </Message>

              <List divided relaxed size="huge">
                <List.Item>
                  <List.Icon name="users" />
                  <List.Content>
                    <List.Header>{competitionInfo.competitor_limit}</List.Header>
                    <List.Description>Competitor Limit</List.Description>
                  </List.Content>
                </List.Item>
                <List.Item>
                  <List.Icon name="money" />
                  <List.Content>
                    <List.Header>
                      {toDecimal(
                          dinero({
                            amount: competitionInfo.base_entry_fee_lowest_denomination,
                            currency: currencies[competitionInfo.currency_code],
                          }),
                          ({ value, currency }) => `${currency.code} ${value}`
                      ) ?? 'No Entry Fee'}
                    </List.Header>
                    <List.Description>Base Registration Fee</List.Description>
                    <List.List>
                      <List.Item>
                        <List.Icon name="user plus" />
                        <List.Content>
                          <List.Header>
                            {toDecimal(
                                dinero({
                                  amount: competitionInfo.guests_entry_fee_lowest_denomination,
                                  currency: currencies[competitionInfo.currency_code],
                                }),
                                ({ value, currency }) => `${currency.code} ${value}`
                            )}
                          </List.Header>
                          <List.Description>Guest Entry Fee</List.Description>
                        </List.Content>
                      </List.Item>
                    </List.List>
                  </List.Content>
                </List.Item>
                <List.Item>
                  <List.Content floated="right">
                    <Label size="huge" color={isRegistrationOpen ? "green" : "red"}>
                      {isRegistrationOpen ? 'OPEN' : 'CLOSED'}
                    </Label>
                  </List.Content>
                  <List.Icon name="pencil" />
                  <List.Content>
                    <List.Header>
                      {moment(competitionInfo.registration_open).calendar()}
                      {' until '}
                      {moment(competitionInfo.registration_close).calendar()}
                    </List.Header>
                    <List.Description>Registration Period</List.Description>
                    <List.List>
                      <List.Item>
                        <List.Icon name="sync" />
                        <List.Content>
                          <List.Header>
                            {competitionInfo.refund_policy_percent}
                            {'% before '}
                            {moment(
                                competitionInfo.refund_policy_limit_date ??
                                competitionInfo.start_date
                            ).calendar()}
                          </List.Header>
                          <List.Description>Refund policy</List.Description>
                        </List.Content>
                      </List.Item>
                      <List.Item>
                        <List.Icon name="save" />
                        <List.Content>
                          <List.Header>
                            {moment(
                                competitionInfo.event_change_deadline_date ??
                                competitionInfo.end_date
                            ).calendar()}
                          </List.Header>
                          <List.Description>Edit registration deadline</List.Description>
                        </List.Content>
                      </List.Item>
                      <List.Item>
                        <List.Icon name="hourglass half" />
                        <List.Content>
                          <List.Header>
                            {moment(
                                competitionInfo.waiting_list_deadline_date ??
                                competitionInfo.start_date
                            ).calendar()}
                          </List.Header>
                          <List.Description>Waiting list acceptance date</List.Description>
                        </List.Content>
                      </List.Item>
                    </List.List>
                  </List.Content>
                </List.Item>
              </List>

              <Button
                  primary
                  size="huge"
                  fluid
                  disabled={
                      !competitionInfo['registration_opened?'] &&
                      !competitionInfo.organizers
                          .concat(competitionInfo.delegates)
                          .find((u) => u.id === user?.id)
                  }
                  onClick={(_, data) => {
                    if (!data.disabled) {
                      if (competitionInfo.use_wca_registration) {
                        navigate(
                            `${BASE_ROUTE}/${competitionInfo.id}/register`
                        )
                      } else {
                        window.location =
                            competitionInfo.external_registration_page
                      }
                    }
                  }}
              >
                Sounds awesome, count me in!
              </Button>
            </Segment>
            <Segment padded attached secondary>
              <List divided relaxed>
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
          {children}
        </>
      )}
    </CompetitionContext.Provider>
  )
}

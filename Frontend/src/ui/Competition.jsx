import * as currencies from '@dinero.js/currencies'
import { useQuery } from '@tanstack/react-query'
import { CubingIcon, UiIcon } from '@thewca/wca-components'
import { dinero, toDecimal } from 'dinero.js'
import moment from 'moment'
import React from 'react'
import { useNavigate, useParams } from 'react-router-dom'
import {
  Button,
  Container,
  Grid,
  Header,
  Image,
  Label,
  Segment,
} from 'semantic-ui-react'
import getCompetitionInfo from '../api/competition/get/get_competition_info'
import { CompetitionContext } from '../api/helper/context/competition_context'
import { BASE_ROUTE } from '../routes'
import styles from './competition.module.scss'
import LoadingMessage from './messages/loadingMessage'

export default function Competition({ children }) {
  const { competition_id } = useParams()
  const navigate = useNavigate()
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
          <Container>
            <Segment padded raised>
              <Grid>
                <Grid.Column width={12}>
                  <Header as="h1">
                    <UiIcon name="bookmark ouline" />
                    {competitionInfo['registration_opened?'] ? (
                      <Header.Content>
                        {competitionInfo.name} | Open
                      </Header.Content>
                    ) : (
                      <Header.Content>
                        {competitionInfo.name} | Close
                      </Header.Content>
                    )}
                    <Header.Subheader>
                      <UiIcon name="pin" /> {competitionInfo.venue_address}
                    </Header.Subheader>
                  </Header>
                  <Header as="h2">
                    {moment(competitionInfo.start_date).format('LL')},{' '}
                    <a
                      href={`https://calendar.google.com/calendar/render?action=TEMPLATE&text=${
                        competitionInfo.id
                      }&dates=${moment(competitionInfo.start_date).format(
                        'YYYYMMDD'
                      )}/${moment(competitionInfo.end_date).format(
                        'YYYYMMDD'
                      )}&location=${competitionInfo.venue_address}`}
                    >
                      Add to Google Calendar
                    </a>
                  </Header>
                  <Segment inverted color="red">
                    *Insert Potential organizer announcement or memo for users
                    to view before hitting register*
                  </Segment>

                  <Button
                    color="orange"
                    size="massive"
                    disabled={!competitionInfo['registration_opened?']}
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
                    Register
                  </Button>
                  <Label size="massive">
                    Registration Fee:{' '}
                    {toDecimal(
                      dinero({
                        amount:
                          competitionInfo.base_entry_fee_lowest_denomination,
                        currency: currencies[competitionInfo.currency_code],
                      }),
                      ({ value, currency }) => `${currency.code} ${value}`
                    ) ?? 'No Entry Fee'}
                  </Label>
                </Grid.Column>
                <Grid.Column width={4}>
                  <Image href={competitionInfo.url} className={styles.image} />
                </Grid.Column>
              </Grid>
            </Segment>
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
                    event={competitionInfo.main_event_id}
                    selected={true}
                  />
                </span>
              </div>
            </div>
          </Container>
          {children}
        </>
      )}
    </CompetitionContext.Provider>
  )
}

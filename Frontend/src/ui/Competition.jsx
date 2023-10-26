import * as currencies from '@dinero.js/currencies'
import { useQuery } from '@tanstack/react-query'
import { CubingIcon, UiIcon } from '@thewca/wca-components'
import { dinero, toDecimal } from 'dinero.js'
import moment from 'moment'
import React, { useContext, useState } from 'react'
import { useNavigate, useParams } from 'react-router-dom'
import { Button, Header, Image, Modal } from 'semantic-ui-react'
import getCompetitionInfo from '../api/competition/get/get_competition_info'
import { CompetitionContext } from '../api/helper/context/competition_context'
import { PermissionsContext } from '../api/helper/context/permission_context'
import { BASE_ROUTE } from '../routes'
import styles from './competition.module.scss'
import LoadingMessage from './messages/loadingMessage'

export default function Competition({ children }) {
  const { competition_id } = useParams()
  const { canAdminCompetitions } = useContext(PermissionsContext)
  const [modalOpen, setModalOpen] = useState(false)
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
          <div className={styles.competitionInfo}>
            <div className={styles.header}>
              <div className={styles.infoLeft}>
                <div className={styles.competitionName}>
                  <UiIcon name="bookmark ouline" /> {competitionInfo.name} |{' '}
                  {competitionInfo['registration_opened?'] ? (
                    <span className={styles.open}>Open</span>
                  ) : (
                    <span className={styles.close}>Close</span>
                  )}
                </div>
                <div className={styles.location}>
                  <UiIcon name="pin" /> {competitionInfo.venue_address}
                </div>
                <div className={styles.date}>
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
                </div>
                <div className={styles.announcement}>
                  *Insert Potential organizer announcement or memo for users to
                  view before hitting register*
                </div>
                {canAdminCompetitions ? (
                  <Modal
                    basic
                    onClose={() => setModalOpen(false)}
                    onOpen={() => setModalOpen(true)}
                    open={modalOpen}
                    size="small"
                    trigger={<Button>Administration</Button>}
                  >
                    <Header icon>Admin Tasks</Header>
                    <Modal.Content>
                      <Button.Group vertical>
                        <Button icon>
                          <UiIcon name="lock" />
                          <a
                            href={`${process.env.WCA_HOST}/competitions/${competition_id}/edit`}
                          >
                            Organizer View
                          </a>
                        </Button>
                        <Button icon>
                          <UiIcon name="cubes" />
                          <a
                            href={`${process.env.WCA_URL}/competitions/${competition_id}/events/edit`}
                          >
                            Manage Events
                          </a>
                        </Button>
                        <Button icon>
                          <UiIcon name="calendar alt" />
                          <a
                            href={`${process.env.WCA_URL}/competitions/${competition_id}/schedule/edit`}
                          >
                            Manage Schedule
                          </a>
                        </Button>
                        <Button icon>
                          <UiIcon name="list ul" />
                          <a
                            href={`${process.env.WCA_URL}/competitions/${competition_id}/tabs`}
                          >
                            Manage Tabs
                          </a>
                        </Button>
                        <Button icon>
                          <UiIcon name="stripe" />
                          <a
                            href={`${process.env.WCA_URL}/competitions/${competition_id}/payment_setup`}
                          >
                            Setup Payment
                          </a>
                        </Button>
                        <Button icon>
                          <UiIcon name="lock" />
                          <a
                            href={`${process.env.WCA_URL}/competitions/${competition_id}/edit/admin`}
                          >
                            Admin View
                          </a>
                        </Button>
                        <Button icon>
                          <UiIcon name="copy" />
                          <a
                            href={`${process.env.WCA_URL}/competitions/${competition_id}/edit/clone_competition`}
                          >
                            Clone
                          </a>
                        </Button>
                        <Button icon>
                          <UiIcon name="pen" />
                          <a
                            href={`${process.env.WCA_URL}/competitions/${competition_id}/report`}
                          >
                            Delegate Report
                          </a>
                        </Button>
                      </Button.Group>
                    </Modal.Content>
                    <Modal.Actions>
                      <Button
                        color="green"
                        inverted
                        onClick={() => setModalOpen(false)}
                      >
                        <UiIcon name="checkmark" /> Back
                      </Button>
                    </Modal.Actions>
                  </Modal>
                ) : (
                  <Button
                    className={styles.registerButton}
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
                )}
                <span className={styles.fee}>
                  Registration Fee:{' '}
                  {toDecimal(
                    dinero({
                      amount:
                        competitionInfo.base_entry_fee_lowest_denomination,
                      currency: currencies[competitionInfo.currency_code],
                    }),
                    ({ value, currency }) => `${currency.code} ${value}`
                  ) ?? 'No Entry Fee'}
                </span>
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
                    event={competitionInfo.main_event_id}
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

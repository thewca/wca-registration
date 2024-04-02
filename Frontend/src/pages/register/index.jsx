import React, { useContext, useState } from 'react'
import { useTranslation } from 'react-i18next'
import {
  Button,
  Icon,
  Label,
  List,
  Message,
  Segment,
  Transition,
} from 'semantic-ui-react'
import { CompetitionContext } from '../../api/helper/context/competition_context'
import { PermissionsContext } from '../../api/helper/context/permission_context'
import { RegistrationContext } from '../../api/helper/context/registration_context'
import { UserContext } from '../../api/helper/context/user_context'
import { getMediumDateString, hasPassed } from '../../lib/dates'
import { displayMoneyISO4217 } from '../../lib/money'
import { RegistrationPermissionMessage } from '../../ui/messages/permissionMessage'
import { ClosedCompetitionMessage } from '../../ui/messages/registrationMessage'
import StepPanel from './components/StepPanel'

function registrationStatusLabel(competitionInfo) {
  if (competitionInfo['registration_opened?']) {
    return 'OPEN'
  }
  return hasPassed(competitionInfo.registration_open)
    ? 'CLOSED'
    : 'NOT YET OPEN'
}

export default function Register() {
  const { user } = useContext(UserContext)
  const { competitionInfo } = useContext(CompetitionContext)
  const { canAttendCompetition } = useContext(PermissionsContext)
  const { isRegistered } = useContext(RegistrationContext)

  // Show Registration Panel instead of Info if already registered
  const [showRegisterSteps, setShowRegisterSteps] = useState(isRegistered)

  const { t } = useTranslation()

  const loggedIn = user !== null

  return (
    <div>
      {competitionInfo['registration_opened?'] ||
      competitionInfo.organizers
        .concat(competitionInfo.delegates)
        .find((u) => u.id === user?.id) ? (
        <div>
          {canAttendCompetition ? (
            <>
              <Segment padded attached raised>
                <Message warning>
                  *Insert Potential organizer announcement or memo for users to
                  view before hitting register*
                </Message>

                <List divided relaxed size="huge">
                  <List.Item>
                    <List.Icon name="users" />
                    <List.Content>
                      <List.Header>
                        {competitionInfo.competitor_limit}
                      </List.Header>
                      <List.Description>
                        {t('competitions.competition_info.competitor_limit')}
                      </List.Description>
                    </List.Content>
                  </List.Item>
                  <List.Item>
                    <List.Icon name="money" />
                    <List.Content>
                      <List.Header>
                        {competitionInfo.base_entry_fee_lowest_denomination
                          ? displayMoneyISO4217(
                              competitionInfo.base_entry_fee_lowest_denomination,
                              competitionInfo.currency_code,
                            )
                          : t('competitions.registration_v2.fees.none')}
                      </List.Header>
                      <List.Description>
                        {t(
                          'competitions.competition_form.labels.entry_fees.base_entry_fee',
                        )}
                      </List.Description>
                      <List.List>
                        <List.Item>
                          <List.Icon name="user plus" />
                          <List.Content>
                            <List.Header>
                              {competitionInfo.guests_entry_fee_lowest_denomination
                                ? displayMoneyISO4217(
                                    competitionInfo.guests_entry_fee_lowest_denomination,
                                    competitionInfo.currency_code,
                                  )
                                : t(
                                    'competitions.competition_form.choices.registration.guest_entry_status.free',
                                  )}
                            </List.Header>
                            <List.Description>
                              {t(
                                'competitions.competition_form.labels.entry_fees.guest_entry_fee',
                              )}
                            </List.Description>
                          </List.Content>
                        </List.Item>
                      </List.List>
                    </List.Content>
                  </List.Item>
                  <List.Item>
                    <List.Content floated="right">
                      <Label
                        size="huge"
                        color={
                          competitionInfo['registration_opened?']
                            ? 'green'
                            : 'red'
                        }
                      >
                        {registrationStatusLabel(competitionInfo)}
                      </Label>
                    </List.Content>
                    <List.Icon name="pencil" />
                    <List.Content>
                      <List.Header>
                        {getMediumDateString(competitionInfo.registration_open)}
                        {' until '}
                        {getMediumDateString(
                          competitionInfo.registration_close,
                        )}
                      </List.Header>
                      <List.Description>
                        {t(
                          'competitions.competition_info.registration_period.label',
                        )}
                      </List.Description>
                      <List.List>
                        <List.Item>
                          <List.Icon name="sync" />
                          <List.Content>
                            <List.Header>
                              {competitionInfo.refund_policy_percent}
                              {'% before '}
                              {getMediumDateString(
                                competitionInfo.refund_policy_limit_date ??
                                  competitionInfo.start_date,
                              )}
                            </List.Header>
                            <List.Description>
                              {t(
                                'competitions.competition_info.refund_policy_html',
                                {
                                  limit_date_and_time: getMediumDateString(
                                    competitionInfo.refund_policy_limit_date ??
                                      competitionInfo.start_date,
                                  ),
                                  refund_policy_percent:
                                    competitionInfo.refund_policy_percent + '%',
                                },
                              )}
                            </List.Description>
                          </List.Content>
                        </List.Item>
                        <List.Item>
                          <List.Icon name="save" />
                          <List.Content>
                            <List.Header>
                              {getMediumDateString(
                                competitionInfo.event_change_deadline_date ??
                                  competitionInfo.end_date,
                              )}
                            </List.Header>
                            <List.Description>
                              {t(
                                'competitions.competition_form.labels.registration.event_change_deadline_date',
                              )}
                            </List.Description>
                          </List.Content>
                        </List.Item>
                        <List.Item>
                          <List.Icon name="hourglass half" />
                          <List.Content>
                            <List.Header>
                              {getMediumDateString(
                                competitionInfo.waiting_list_deadline_date ??
                                  competitionInfo.start_date,
                              )}
                            </List.Header>
                            <List.Description>
                              {t(
                                'competitions.competition_form.labels.registration.waiting_list_deadline_date',
                              )}
                            </List.Description>
                          </List.Content>
                        </List.Item>
                      </List.List>
                    </List.Content>
                  </List.Item>
                </List>

                <Transition
                  visible={!showRegisterSteps}
                  duration={500}
                  animation="scale"
                  unmountOnHide
                >
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
                          setShowRegisterSteps(true)
                        } else {
                          window.location =
                            competitionInfo.external_registration_page
                        }
                      }
                    }}
                  >
                    {t('registrations.new_registration.title', {
                      comp: competitionInfo.name,
                    })}
                  </Button>
                </Transition>
              </Segment>

              <Transition
                visible={showRegisterSteps}
                duration={500}
                animation="scale"
              >
                <Segment padded basic>
                  <Button
                    floated="right"
                    icon
                    basic
                    onClick={() => setShowRegisterSteps(false)}
                  >
                    <Icon name="close" />
                  </Button>
                  <StepPanel />
                </Segment>
              </Transition>
            </>
          ) : (
            <RegistrationPermissionMessage
              loggedIn={loggedIn}
              userInfo={user}
            />
          )}
        </div>
      ) : (
        <ClosedCompetitionMessage
          loggedIn={loggedIn}
          competitionRegistrationEnd={competitionInfo.registration_open}
          competitionRegistrationStart={competitionInfo.registration_close}
        />
      )}
    </div>
  )
}

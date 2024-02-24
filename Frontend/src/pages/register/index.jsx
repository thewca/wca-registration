import { DateTime } from 'luxon'
import React, { useContext, useState } from 'react'
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
import { UserContext } from '../../api/helper/context/user_context'
import {
  getLongDateString,
  getMediumDateString,
  hasPassed,
} from '../../lib/dates'
import { displayMoneyISO4217 } from '../../lib/money'
import PermissionMessage from '../../ui/messages/permissionMessage'
import StepPanel from './components/StepPanel'
import {RegistrationContext} from "../../api/helper/context/registration_context";

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
                      <List.Description>Competitor Limit</List.Description>
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
                          : 'No Entry Fee'}
                      </List.Header>
                      <List.Description>Base Registration Fee</List.Description>
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
                                : 'Guests attend for free'}
                            </List.Header>
                            <List.Description>Guest Entry Fee</List.Description>
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
                      <List.Description>Registration Period</List.Description>
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
                            <List.Description>Refund policy</List.Description>
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
                              Edit registration deadline
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
                              Waiting list acceptance date
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
                    Sounds awesome, count me in!
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
            <PermissionMessage>
              {loggedIn
                ? 'You are not allowed to Register for a competition, make sure your profile is complete and you are not banned.'
                : 'You need to log in to Register for a competition.'}
            </PermissionMessage>
          )}
        </div>
      ) : (
        <Message warning>
          {hasPassed(competitionInfo.registration_close)
            ? `Competition Registration closed on ${getMediumDateString(
                competitionInfo.registration_close,
              )}`
            : `Competition Registration will open ${DateTime.fromISO(
                competitionInfo.registration_open,
              ).toRelativeCalendar()} on ${getLongDateString(
                competitionInfo.registration_open,
              )}, ${
                !loggedIn ? 'you will need a WCA Account to register' : ''
              }`}
        </Message>
      )}
    </div>
  )
}

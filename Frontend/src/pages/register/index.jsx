import moment from 'moment'
import React, {useContext, useState} from 'react'
import {Button, Label, List, Message, Segment, Transition} from 'semantic-ui-react'
import { CompetitionContext } from '../../api/helper/context/competition_context'
import { PermissionsContext } from '../../api/helper/context/permission_context'
import { UserContext } from '../../api/helper/context/user_context'
import PermissionMessage from '../../ui/messages/permissionMessage'
import StepPanel from './components/StepPanel'
import styles from './index.module.scss'
import {dinero, toDecimal} from "dinero.js";
import * as currencies from "@dinero.js/currencies";

export default function Register() {
  const { user } = useContext(UserContext)
  const { competitionInfo } = useContext(CompetitionContext)
  const { canAttendCompetition } = useContext(PermissionsContext)

  const [showRegisterSteps, setShowRegisterSteps] = useState(false);

  const loggedIn = user !== null

  const regOpenDate = new Date(competitionInfo?.registration_open)
  const regClosingDate = new Date(competitionInfo?.registration_close)

  const now = Date.now();

  const isRegistrationOpen = regOpenDate <= now && regClosingDate >= now;

  return (
    <div>
      {competitionInfo['registration_opened?'] ||
      competitionInfo.organizers
        .concat(competitionInfo.delegates)
        .find((u) => u.id === user?.id) ? (
        <div>
          {canAttendCompetition ? (
            <>
              <Transition visible={showRegisterSteps} duration={500} animation="fly down">
                <Segment padded basic>
                  <StepPanel />
                </Segment>
              </Transition>
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
                          setShowRegisterSteps(true);
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
        <div className={styles.competitionNotOpen}>
          <Message warning>
            {moment(competitionInfo.registration_open).diff(moment.now()) < 0
              ? `Competition Registration closed on ${moment(
                  competitionInfo.registration_close
                ).format('ll')}`
              : `Competition Registration will open in ${moment(
                  competitionInfo.registration_open
                ).fromNow()} on ${moment(
                  competitionInfo.registration_open
                ).format('lll')}, ${
                  !loggedIn ? 'you will need a WCA Account to register' : ''
                }`}
          </Message>
        </div>
      )}
    </div>
  )
}

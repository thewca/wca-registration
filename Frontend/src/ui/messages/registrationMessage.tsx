import React from 'react'
import { useTranslation } from 'react-i18next'
import { Message } from 'semantic-ui-react'
import {
  getLongDateString,
  getMediumDateString,
  hasPassed,
} from '../../lib/dates'

interface ClosedCompetitionMessageProps {
  loggedIn: boolean
  competitionRegistrationStart: string
  competitionRegistrationEnd: string
}
export function ClosedCompetitionMessage({
  loggedIn,
  competitionRegistrationStart,
  competitionRegistrationEnd,
}: ClosedCompetitionMessageProps) {
  const { t } = useTranslation()
  let key = ''
  if (hasPassed(competitionRegistrationEnd)) {
    key = 'competitions.competition_info.registration_period.range_past_html'
  } else {
    key = `competitions.competition_info.registration_period.range_future_html`
  }

  return (
    <Message warning>
      {t(key, {
        start_date_and_time: getMediumDateString(competitionRegistrationEnd),
        end_date_and_time: getLongDateString(competitionRegistrationStart),
      })}
      {loggedIn && t('registrations.please_sign_in_html')}
    </Message>
  )
}

import {
  getLongDateString,
  getMediumDateString,
  hasPassed,
} from '../../lib/dates'
import { Message } from 'semantic-ui-react'
import React from 'react'
import { useTranslation } from 'react-i18next'
import i18n from '../../i18n'

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
  const { t } = useTranslation('translation', { i18n })
  let key = ''
  if (hasPassed(competitionRegistrationEnd)) {
    key = 'competitions.competition_info.registration_period.range_past_html'
  }
  key = `competitions.competition_info.registration_period.range_past_html`

  return (
    <Message warning>
      {t(key, {
        start_date_and_time: getMediumDateString(competitionRegistrationEnd),
        end_date_and_time: getLongDateString(competitionRegistrationStart),
      })}
      {loggedIn && t('api.login_message')}
    </Message>
  )
}

import { useQuery } from '@tanstack/react-query'
import { getEventName, getFormatName } from '@wca/helpers'
import React, { useContext } from 'react'
import { useTranslation } from 'react-i18next'
import {
  Message,
  Segment,
  Table,
  TableBody,
  TableCell,
  TableHeader,
  TableHeaderCell,
  TableRow,
} from 'semantic-ui-react'
import getCompetitionWcif from '../../api/competition/get/get_competition_wcif'
import { CompetitionContext } from '../../api/helper/context/competition_context'
import {
  attemptResultToString,
  centiSecondsToHumanReadable,
} from '../../lib/solveTime'
import { setMessage } from '../../ui/events/messages'
import LoadingMessage from '../../ui/messages/loadingMessage'

export default function Events() {
  const { competitionInfo } = useContext(CompetitionContext)
  const { t } = useTranslation()
  const {
    isLoading,
    isError,
    data: wcif,
  } = useQuery({
    queryKey: ['wcif', competitionInfo.id],
    queryFn: () => getCompetitionWcif(competitionInfo.id),
    retry: false,
    onError: (err) => {
      setMessage(err.message, 'error')
    },
  })

  if (isError) {
    return <Message>{t('competitions.registration_v2.errors.events')}</Message>
  }

  return isLoading ? (
    <LoadingMessage />
  ) : (
    <Segment attached padded>
      <Table striped>
        <TableHeader>
          <TableRow>
            <TableHeaderCell>
              {t('competitions.results_table.event')}
            </TableHeaderCell>
            <TableHeaderCell>
              {t('competitions.results_table.round')}
            </TableHeaderCell>
            <TableHeaderCell>{t('competitions.events.format')}</TableHeaderCell>
            <TableHeaderCell>
              {t('competitions.events.time_limit')}
            </TableHeaderCell>
            {competitionInfo['uses_cutoff?'] && (
              <TableHeaderCell>
                {t('competitions.events.cutoff')}
              </TableHeaderCell>
            )}
            <TableHeaderCell>
              {t('competitions.events.proceed')}
            </TableHeaderCell>
            {competitionInfo['uses_qualification?'] && (
              <TableHeaderCell>
                {t('competitions.events.qualification')}
              </TableHeaderCell>
            )}
          </TableRow>
        </TableHeader>

        <TableBody>
          {wcif.events.map((event) => {
            return event.rounds.map((round, i) => {
              return (
                <TableRow key={round.id}>
                  <TableCell
                    className={
                      i === event.rounds.length - 1 ? 'last-round' : ''
                    }
                  >
                    {i === 0 && getEventName(event.id)}
                  </TableCell>
                  <TableCell>{i + 1}</TableCell>
                  <TableCell>{getFormatName(round.format)}</TableCell>
                  <TableCell>
                    {round.timeLimit &&
                      centiSecondsToHumanReadable({
                        c: round.timeLimit.centiseconds,
                      })}
                  </TableCell>
                  {competitionInfo['uses_cutoff?'] && (
                    <TableCell>
                      {round.cutoff &&
                        attemptResultToString({
                          attemptResult: round.cutoff.attemptResult,
                          eventId: event.id,
                        })}
                    </TableCell>
                  )}
                  <TableCell>
                    {round.advancementCondition &&
                      `Top ${round.advancementCondition.level} ${round.advancementCondition.type} proceed`}
                  </TableCell>
                  {competitionInfo['uses_qualification?'] && (
                    <TableCell>{event.qualification}</TableCell>
                  )}
                </TableRow>
              )
            })
          })}
        </TableBody>
      </Table>
    </Segment>
  )
}

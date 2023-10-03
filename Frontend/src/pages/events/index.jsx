import { getEventName, getFormatName } from '@wca/helpers'
import React, { useContext } from 'react'
import {
  Table,
  TableBody,
  TableCell,
  TableHeader,
  TableHeaderCell,
  TableRow,
} from 'semantic-ui-react'
import { CompetitionContext } from '../../api/helper/context/competition_context'
import styles from './index.module.scss'

export default function Events() {
  const { competitionInfo } = useContext(CompetitionContext)
  return (
    <div style={styles.eventsWrapper}>
      <Table striped>
        <TableHeader>
          <TableRow>
            <TableHeaderCell>Event</TableHeaderCell>
            <TableHeaderCell>Round</TableHeaderCell>
            <TableHeaderCell>Format</TableHeaderCell>
            <TableHeaderCell>Time Limit</TableHeaderCell>
            {competitionInfo['uses_cutoff?'] && (
              <TableHeaderCell>Cutoff</TableHeaderCell>
            )}
            <TableHeaderCell>Proceed</TableHeaderCell>
            {competitionInfo['uses_qualification?'] && (
              <TableHeaderCell>Qualification</TableHeaderCell>
            )}
          </TableRow>
        </TableHeader>

        <TableBody>
          {competitionInfo.events_with_rounds.map((event) => {
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
                      `${round.timeLimit.centiseconds / 100} seconds`}
                  </TableCell>
                  {competitionInfo['uses_cutoff?'] && (
                    <TableCell>
                      {round.cutoff &&
                        `${round.cutoff?.attemptResult / 100} seconds`}
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
    </div>
  )
}

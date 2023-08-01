import React, { useContext } from 'react'
import { CompetitionContext } from '../../api/helper/context/competition_context'
import styles from './index.module.scss'
import { Table, TableCell } from 'semantic-ui-react'
import moment from 'moment'
import { getFormatName } from '@wca/helpers'

const getDatesBetween = (startDate, endDate) => {
  const currentDate = new Date(startDate)
  const dates = [currentDate]
  // eslint doesn't get that we modify with setDate
  // eslint-disable-next-line no-unmodified-loop-condition
  while (currentDate <= endDate) {
    dates.push(new Date(currentDate))
    currentDate.setDate(currentDate.getDate() + 1)
  }
  return dates
}

const activitiesByDate = (activities, date) => {
  return activities.filter(
    (activity) => new Date(activity.startTime).getDate() === date.getDate()
  )
}

export default function Schedule() {
  const { competitionInfo } = useContext(CompetitionContext)
  const competitionDays = getDatesBetween(
    competitionInfo.start_date,
    competitionInfo.end_date
  )
  return (
    <div>
      {competitionDays.map((date) => {
        const activitiesForDay = activitiesByDate(
          competitionInfo.schedule_wcif.venues.flatMap((venue) =>
            venue.rooms.flatMap((room) => room.activities)
          ),
          date
        ).sort((a, b) => new Date(a.startTime) > new Date(b.startTime))
        return (
          <div key={date.toLocaleString()}>
            <h2>Schedule for {moment(date).format('ll')}</h2>
            <Table>
              <Table.Header>
                <Table.Row>
                  <Table.HeaderCell>Start</Table.HeaderCell>
                  <Table.HeaderCell>End</Table.HeaderCell>
                  <Table.HeaderCell>Activity</Table.HeaderCell>
                  <Table.HeaderCell>Room</Table.HeaderCell>
                  <Table.HeaderCell>Format</Table.HeaderCell>
                  <Table.HeaderCell>Time Limit</Table.HeaderCell>
                  <Table.HeaderCell>Time Cutoff</Table.HeaderCell>
                  <Table.HeaderCell>Proceed</Table.HeaderCell>
                </Table.Row>
              </Table.Header>
              <Table.Body>
                {activitiesForDay.map((activity) => {
                  const round = competitionInfo.events_with_rounds
                    .flatMap((events) => events.rounds)
                    .find((round) => round.id === activity.activityCode)
                  const room = competitionInfo.schedule_wcif.venues
                    .flatMap((venue) => venue.rooms)
                    .find((room) =>
                      room.activities.some(
                        (ac) => ac.activityCode === activity.activityCode
                      )
                    )
                  return (
                    <Table.Row key={activity.id}>
                      <Table.Cell>
                        {moment(activity.startTime).format('HH:mm')}
                      </Table.Cell>
                      <Table.Cell>
                        {moment(activity.endTime).format('HH:mm')}
                      </Table.Cell>
                      <Table.Cell>{activity.name}</Table.Cell>
                      <Table.Cell>{room.name}</Table.Cell>
                      <Table.Cell>
                        {round?.format && getFormatName(round.format)}
                      </Table.Cell>
                      <TableCell>
                        {round?.timeLimit &&
                          `${round.timeLimit.centiseconds / 100} seconds`}
                      </TableCell>
                      <TableCell>
                        {round?.cutoff &&
                          `${round.cutoff?.attemptResult / 100} seconds`}
                      </TableCell>
                      <TableCell>
                        {round?.advancementCondition &&
                          `Top ${round.advancementCondition.level} ${round.advancementCondition.type} proceed`}
                      </TableCell>
                    </Table.Row>
                  )
                })}
              </Table.Body>
            </Table>
          </div>
        )
      })}
    </div>
  )
}

import { getFormatName } from '@wca/helpers'
import moment from 'moment'
import React, { useContext } from 'react'
import { Table, TableCell } from 'semantic-ui-react'
import { CompetitionContext } from '../../api/helper/context/competition_context'
import styles from './index.module.scss'
import { useQuery } from '@tanstack/react-query'
import { setMessage } from '../../ui/events/messages'
import getCompetitionWcif from '../../api/competition/get/get_competition_wcif'
import LoadingMessage from '../../ui/messages/loadingMessage'

const getDatesBetween = (startDate, numberOfDays) => {
  const range = []
  for (let i = 0; i < numberOfDays; i++) {
    range.push(moment(startDate).add(i, 'days').toDate())
  }
  return range
}

const activitiesByDate = (activities, date) => {
  return activities.filter(
    (activity) => new Date(activity.startTime).getDate() === date.getDate()
  )
}

export default function Schedule() {
  const { competitionInfo } = useContext(CompetitionContext)
  const { isLoading, data: wcif } = useQuery({
    queryKey: ['wcif', competitionInfo.id],
    queryFn: () => getCompetitionWcif(competitionInfo.id),
    retry: false,
    onError: (err) => setMessage(err.message, 'error'),
  })

  return isLoading ? (
    <LoadingMessage />
  ) : (
    <div className={styles.scheduleWrapper}>
      {getDatesBetween(wcif.schedule.startDate, wcif.schedule.numberOfDays).map(
        (date, index) => {
          const activitiesForDay = activitiesByDate(
            wcif.schedule.venues.flatMap((venue) =>
              venue.rooms.flatMap((room) => room.activities)
            ),
            date
          ).sort((a, b) => new Date(a.startTime) > new Date(b.startTime))
          return (
            <div
              key={date.toLocaleString()}
              className={`${
                index === wcif.schedule.numberOfDays - 1
                  ? styles.scheduleTable
                  : ''
              }`}
            >
              <h2>Schedule for {moment(date).format('ll')}</h2>
              <Table striped>
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
        }
      )}
    </div>
  )
}

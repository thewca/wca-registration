import { useQuery } from '@tanstack/react-query'
import { getFormatName } from '@wca/helpers'
import moment from 'moment'
import React, { useContext } from 'react'
import { Header, Message, Segment, Table, TableCell } from 'semantic-ui-react'
import getCompetitionWcif from '../../api/competition/get/get_competition_wcif'
import { CompetitionContext } from '../../api/helper/context/competition_context'
import { setMessage } from '../../ui/events/messages'
import LoadingMessage from '../../ui/messages/loadingMessage'

const getDatesStartingOn = (startDate, numberOfDays) => {
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

  const {
    isLoading,
    isError,
    data: wcif,
  } = useQuery({
    queryKey: ['wcif', competitionInfo.id],
    queryFn: () => getCompetitionWcif(competitionInfo.id),
    retry: false,
    onError: (err) => setMessage(err.message, 'error'),
  })

  if (isError) {
    return <Message>Loading the schedule failed, please try again.</Message>
  }

  return isLoading ? (
    <LoadingMessage />
  ) : (
    <Segment padded attached>
      {getDatesStartingOn(
        wcif.schedule.startDate,
        wcif.schedule.numberOfDays
      ).map((date) => {
        const activitiesForDay = activitiesByDate(
          wcif.schedule.venues.flatMap((venue) =>
            venue.rooms.flatMap((room) => room.activities)
          ),
          date
        )
        const rounds = wcif.events.flatMap((events) => events.rounds)
        const rooms = wcif.schedule.venues.flatMap((venue) => venue.rooms)

        return (
          <ScheduleOnDate
            key={date.getDate()}
            date={date}
            activities={activitiesForDay}
            rounds={rounds}
            rooms={rooms}
          />
        )
      })}
    </Segment>
  )
}

function ScheduleOnDate({ date, activities, rounds, rooms }) {
  const sortedActivities = activities.sort(
    (a, b) => new Date(a.startTime) > new Date(b.startTime)
  )

  return (
    <Segment basic>
      <Header as="h2">Schedule for {moment(date).format('ll')}</Header>
      <Table striped>
        <ScheduleHeaderRow />
        <Table.Body>
          {sortedActivities.map((activity) => {
            const round = rounds.find(
              (round) => round.id === activity.activityCode
            )
            const room = rooms.find((room) =>
              room.activities.some(
                (ac) => ac.activityCode === activity.activityCode
              )
            )

            return (
              <ScheduleActivityRow
                key={activity.id}
                activity={activity}
                round={round}
                room={room}
              />
            )
          })}
        </Table.Body>
      </Table>
    </Segment>
  )
}

function ScheduleHeaderRow() {
  return (
    <Table.Header>
      <Table.Row>
        <Table.HeaderCell>Start</Table.HeaderCell>
        <Table.HeaderCell>End</Table.HeaderCell>
        <Table.HeaderCell>Activity</Table.HeaderCell>
        <Table.HeaderCell>Room</Table.HeaderCell>
        <Table.HeaderCell>Format</Table.HeaderCell>
        <Table.HeaderCell>Time Limit</Table.HeaderCell>
        <Table.HeaderCell>Cutoff</Table.HeaderCell>
        <Table.HeaderCell>Proceed</Table.HeaderCell>
      </Table.Row>
    </Table.Header>
  )
}

function ScheduleActivityRow({ activity, round, room }) {
  // note: round/room may be undefined for custom activities like lunch

  const { name, startTime, endTime } = activity

  return (
    <Table.Row>
      <Table.Cell>{moment(startTime).format('HH:mm')}</Table.Cell>
      <Table.Cell>{moment(endTime).format('HH:mm')}</Table.Cell>

      <Table.Cell>{name}</Table.Cell>

      <Table.Cell>{room.name}</Table.Cell>

      <Table.Cell>{round?.format && getFormatName(round.format)}</Table.Cell>
      <TableCell>
        {round?.timeLimit && `${round.timeLimit.centiseconds / 100} seconds`}
      </TableCell>
      <TableCell>
        {round?.cutoff && `${round.cutoff.attemptResult / 100} seconds`}
      </TableCell>
      <TableCell>
        {round?.advancementCondition &&
          `Top ${round.advancementCondition.level} ${round.advancementCondition.type} proceed`}
      </TableCell>
    </Table.Row>
  )
}

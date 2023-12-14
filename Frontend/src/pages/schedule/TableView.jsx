import { getFormatName } from '@wca/helpers'
import moment from 'moment'
import React, { useState } from 'react'
import { Checkbox, Header, Segment, Table, TableCell } from 'semantic-ui-react'

export default function TableView({
  timeZone,
  wcifSchedule,
  venuesShown,
  events,
}) {
  const [isExpanded, setIsExpanded] = useState(false)

  // TODO: add extra day either end to account for time zone shifts
  const dates = getDatesStartingOn(
    wcifSchedule.startDate,
    wcifSchedule.numberOfDays
  )
  const rounds = events.flatMap((event) => event.rounds)
  const rooms = venuesShown.flatMap((venue) => venue.rooms)

  return (
    <>
      <Checkbox
        name="details"
        label="Show Round Details"
        toggle
        checked={isExpanded}
        onChange={(_, data) => setIsExpanded(data.checked)}
      />

      {dates.map((date) => {
        // TODO: combine 'same' activities in different rooms into 1 row
        const activitiesForDay = activitiesByDate(
          rooms.flatMap((room) => room.activities),
          date,
          timeZone
        )

        return (
          <SingleDayTable
            key={date.getDate()}
            date={date}
            timeZone={timeZone}
            activities={activitiesForDay}
            rounds={rounds}
            rooms={rooms}
            isExpanded={isExpanded}
          />
        )
      })}
    </>
  )
}

function SingleDayTable({
  date,
  timeZone,
  activities,
  rounds,
  rooms,
  isExpanded,
}) {
  const title = `Schedule for ${getLongDate(date)}`
  const sortedActivities = [...activities].sort(earliestWithLongestTieBreaker)

  return (
    <Segment basic>
      <Header as="h2">{title}</Header>

      <Table striped>
        <Table.Header>
          <HeaderRow isExpanded={isExpanded} />
        </Table.Header>

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
              <ActivityRow
                key={activity.id}
                isExpanded={isExpanded}
                activity={activity}
                round={round}
                room={room}
                timeZone={timeZone}
              />
            )
          })}
        </Table.Body>
      </Table>
    </Segment>
  )
}

function HeaderRow({ isExpanded }) {
  return (
    <Table.Row>
      <Table.HeaderCell>Start</Table.HeaderCell>
      <Table.HeaderCell>End</Table.HeaderCell>
      <Table.HeaderCell>Activity</Table.HeaderCell>
      <Table.HeaderCell>Room</Table.HeaderCell>
      {isExpanded && (
        <>
          <Table.HeaderCell>Format</Table.HeaderCell>
          <Table.HeaderCell>Time Limit</Table.HeaderCell>
          <Table.HeaderCell>Cutoff</Table.HeaderCell>
          <Table.HeaderCell>Proceed</Table.HeaderCell>
        </>
      )}
    </Table.Row>
  )
}

function ActivityRow({ isExpanded, activity, round, room, timeZone }) {
  const { name, startTime, endTime } = activity
  // note: round may be undefined for custom activities like lunch
  const { format, timeLimit, cutoff, advancementCondition } = round || {}

  // TODO: room is wrong when viewing all venues
  // TODO: show venue name when viewing multiple venues
  // TODO: name is inconsistent with existing wca schedule (and sometimes is in french)
  // TODO: format and time limit not showing up for FM

  return (
    <Table.Row>
      <Table.Cell>{getShortTime(startTime, timeZone)}</Table.Cell>

      <Table.Cell>{getShortTime(endTime, timeZone)}</Table.Cell>

      <Table.Cell>{name}</Table.Cell>

      <Table.Cell>{room.name}</Table.Cell>

      {isExpanded && (
        <>
          <Table.Cell>{format && getFormatName(format)}</Table.Cell>

          <TableCell>
            {timeLimit && `${timeLimit.centiseconds / 100} seconds`}
          </TableCell>

          <TableCell>
            {cutoff && `${cutoff.attemptResult / 100} seconds`}
          </TableCell>

          <TableCell>
            {advancementCondition &&
              `Top ${advancementCondition.level} ${advancementCondition.type} proceed`}
          </TableCell>
        </>
      )}
    </Table.Row>
  )
}

// TODO: move to separate utils file

const earliestWithLongestTieBreaker = (a, b) => {
  if (a.startTime < b.startTime) {
    return -1
  }
  if (a.startTime > b.startTime) {
    return 1
  }
  if (a.endTime < b.endTime) {
    return 1
  }
  if (a.endTime > b.endTime) {
    return -1
  }
  return 0
}

const getDatesStartingOn = (startDate, numberOfDays) => {
  const range = []
  for (let i = 0; i < numberOfDays; i++) {
    range.push(moment(startDate).add(i, 'days').toDate())
  }
  return range
}

const activitiesByDate = (activities, date, timeZone) => {
  return activities.filter(
    // not sure how to check startTime *in timeZone* is on date, besides
    // comparing locale strings, which seems bad
    // (there's only .getDay() for local time zone and .getUTCDay() for UTC,
    // but no such function for arbitrary time zone)
    (activity) =>
      new Date(activity.startTime).toLocaleDateString([], { timeZone }) ===
      date.toLocaleDateString()
  )
}

const getShortTime = (date, timeZone) => {
  return new Date(date).toLocaleTimeString([], {
    timeStyle: 'short',
    timeZone,
  })
}

const getLongDate = (date) => {
  return new Date(date).toLocaleDateString([], {
    weekday: 'long',
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  })
}

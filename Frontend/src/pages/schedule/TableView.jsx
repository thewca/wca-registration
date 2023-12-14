import { getFormatName } from '@wca/helpers'
import React, { useState } from 'react'
import { Checkbox, Header, Segment, Table, TableCell } from 'semantic-ui-react'

export default function TableView({ dates, timeZone, venuesShown, events }) {
  const rounds = events.flatMap((event) => event.rounds)
  const allRooms = venuesShown.flatMap((venue) => venue.rooms)
  const sortedActivities = allRooms
    .flatMap((room) => room.activities)
    .sort(earliestWithLongestTieBreaker)

  const [isExpanded, setIsExpanded] = useState(false)

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
        const activitiesForDay = activitiesByDate(
          sortedActivities,
          date,
          timeZone
        )
        const groupedActivitiesForDay = groupActivities(activitiesForDay)

        return (
          <SingleDayTable
            key={date.getDate()}
            date={date}
            timeZone={timeZone}
            groupedActivities={groupedActivitiesForDay}
            rounds={rounds}
            allRooms={allRooms}
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
  groupedActivities,
  rounds,
  allRooms,
  isExpanded,
}) {
  const title = `Schedule for ${getLongDate(date)}`

  return (
    <Segment basic>
      <Header as="h2">{title}</Header>

      <Table striped>
        <Table.Header>
          <HeaderRow isExpanded={isExpanded} />
        </Table.Header>

        <Table.Body>
          {groupedActivities.map((activityGroup) => {
            const activityRound = rounds.find(
              (round) => round.id === activityGroup[0].activityCode
            )

            return (
              <ActivityRow
                key={activityGroup[0].id}
                isExpanded={isExpanded}
                activityGroup={activityGroup}
                round={activityRound}
                allRooms={allRooms}
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
      <Table.HeaderCell>Room(s) or Stage(s)</Table.HeaderCell>
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

function ActivityRow({ isExpanded, activityGroup, round, allRooms, timeZone }) {
  const { name, startTime, endTime } = activityGroup[0]
  const activityIds = activityGroup.map((activity) => activity.id)
  // note: round may be undefined for custom activities like lunch
  const { format, timeLimit, cutoff, advancementCondition } = round || {}
  const rooms = allRooms.filter((room) =>
    room.activities.some((activity) => activityIds.includes(activity.id))
  )

  // TODO: create name from activity code when possible (fallback to name property)
  // TODO: format and time limit not showing up for attempt-based activities (fm, multi)

  return (
    <Table.Row>
      <Table.Cell>{getShortTime(startTime, timeZone)}</Table.Cell>

      <Table.Cell>{getShortTime(endTime, timeZone)}</Table.Cell>

      <Table.Cell>{name}</Table.Cell>

      <Table.Cell>{rooms.map((room) => room.name).join(', ')}</Table.Cell>

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

// assumes they are sorted
const groupActivities = (activities) => {
  const grouped = []
  activities.forEach((activity) => {
    if (
      grouped.length > 0 &&
      areGroupable(activity, grouped[grouped.length - 1][0])
    ) {
      grouped[grouped.length - 1].push(activity)
    } else {
      grouped.push([activity])
    }
  })
  return grouped
}

const areGroupable = (act1, act2) => {
  return (
    act1.startTime === act2.startTime &&
    act1.endTime === act2.endTime &&
    act1.activityCode === act2.activityCode
  )
}

import { getFormatName } from '@wca/helpers'
import React, { useState } from 'react'
import { Checkbox, Header, Segment, Table, TableCell } from 'semantic-ui-react'
import {
  earliestWithLongestTieBreaker,
  getActivityEvent,
  groupActivities,
} from '../../lib/activities'
import { activitiesByDate, getLongDate, getShortTime } from '../../lib/dates'

export default function TableView({ dates, timeZone, rooms, activeEvents }) {
  const rounds = activeEvents.flatMap((event) => event.rounds)

  const [isExpanded, setIsExpanded] = useState(false)

  const sortedActivities = rooms
    .flatMap((room) => room.activities)
    .sort(earliestWithLongestTieBreaker)

  const eventIds = activeEvents.map(({ id }) => id)
  const visibleActivities = sortedActivities.filter((activity) =>
    ['other', ...eventIds].includes(getActivityEvent(activity))
  )

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
          visibleActivities,
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
  groupedActivities,
  rounds,
  rooms,
  isExpanded,
}) {
  const title = `Schedule for ${getLongDate(date, timeZone)}`

  return (
    <Segment basic>
      <Header as="h2">{title}</Header>

      <Table striped>
        <Table.Header>
          <HeaderRow isExpanded={isExpanded} />
        </Table.Header>

        <Table.Body>
          {groupedActivities.length > 0 ? (
            groupedActivities.map((activityGroup) => {
              const activityRound = rounds.find(
                (round) => round.id === activityGroup[0].activityCode
              )

              return (
                <ActivityRow
                  key={activityGroup[0].id}
                  isExpanded={isExpanded}
                  activityGroup={activityGroup}
                  round={activityRound}
                  rooms={rooms}
                  timeZone={timeZone}
                />
              )
            })
          ) : (
            <Table.Row>
              <Table.Cell colSpan={4}>
                <em>No activities for the selected rooms/events.</em>
              </Table.Cell>
            </Table.Row>
          )}
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

function ActivityRow({ isExpanded, activityGroup, round, rooms, timeZone }) {
  const { name, startTime, endTime } = activityGroup[0]
  const activityIds = activityGroup.map((activity) => activity.id)
  // note: round may be undefined for custom activities like lunch
  const { format, timeLimit, cutoff, advancementCondition } = round || {}
  const roomsUsed = rooms.filter((room) =>
    room.activities.some((activity) => activityIds.includes(activity.id))
  )

  // TODO: create name from activity code when possible (fallback to name property)
  // TODO: format and time limit not showing up for attempt-based activities (fm, multi)
  // TODO: display times in appropriate format

  return (
    <Table.Row>
      <Table.Cell>{getShortTime(startTime, timeZone)}</Table.Cell>

      <Table.Cell>{getShortTime(endTime, timeZone)}</Table.Cell>

      <Table.Cell>{name}</Table.Cell>

      <Table.Cell>{roomsUsed.map((room) => room.name).join(', ')}</Table.Cell>

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

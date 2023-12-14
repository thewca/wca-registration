import { getFormatName } from '@wca/helpers'
import React, { useReducer, useState } from 'react'
import { Checkbox, Header, Segment, Table, TableCell } from 'semantic-ui-react'
import {
  earliestWithLongestTieBreaker,
  groupActivities,
} from '../../lib/activities'
import { activitiesByDate, getLongDate, getShortTime } from '../../lib/dates'

const roomsReducer = (state, { type, id }) => {
  let newState = [...state]

  switch (type) {
    case 'toggle':
      if (newState.includes(id)) {
        newState = newState.filter((x) => x !== id)
      } else {
        newState.push(id)
      }
      return newState

    default:
      throw new Error('Unknown action.')
  }
}

export default function TableView({ dates, timeZone, venuesShown, events }) {
  const rounds = events.flatMap((event) => event.rounds)
  const allRooms = venuesShown.flatMap((venue) => venue.rooms)

  const [isExpanded, setIsExpanded] = useState(false)

  // TODO: reset on venue change
  const [activeRoomIds, dispatchRooms] = useReducer(
    roomsReducer,
    allRooms.map((room) => room.id)
  )

  const activeRooms = allRooms.filter((room) => activeRoomIds.includes(room.id))
  const sortedActivities = activeRooms
    .flatMap((room) => room.activities)
    .sort(earliestWithLongestTieBreaker)

  return (
    <>
      <Checkbox
        name="details"
        label="Show Round Details"
        toggle
        checked={isExpanded}
        onChange={(_, data) => setIsExpanded(data.checked)}
      />

      <RoomSelector
        allRooms={allRooms}
        activeRooms={activeRoomIds}
        toggleRoom={(id) => dispatchRooms({ type: 'toggle', id })}
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

// TODO: clean up UI
function RoomSelector({ allRooms, activeRooms, toggleRoom }) {
  return allRooms.map(({ id, name, color }) => (
    <Checkbox
      key={id}
      checked={activeRooms.includes(id)}
      label={name + ' (' + color + ')'}
      onChange={() => toggleRoom(id)}
    />
  ))
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

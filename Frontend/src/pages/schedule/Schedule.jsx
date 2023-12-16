import React, { useReducer, useState } from 'react'
import { Checkbox, Dropdown, Form, Message, Segment } from 'semantic-ui-react'
import { getDatesStartingOn } from '../../lib/dates'
import CalendarView from './CalendarView'
import TableView from './TableView'
import VenuesAndRooms from './VenuesAndRooms'
import EventsSelector from './EventsSelector'

const activeIdReducer = (state, { type, id, ids }) => {
  let newState = [...state]

  switch (type) {
    case 'toggle':
      if (newState.includes(id)) {
        newState = newState.filter((x) => x !== id)
      } else {
        newState.push(id)
      }
      return newState

    case 'reset':
      return ids ?? []

    default:
      throw new Error('Unknown action.')
  }
}

export default function Schedule({ wcif }) {
  // view

  const [activeView, setActiveView] = useState('calendar')

  // venues

  const venues = wcif.schedule.venues
  const venueCount = venues.length
  const [activeVenueIndex, setActiveVenueIndex] = useState(-1)
  const activeVenueOrNull =
    venueCount === 1
      ? venues[0] // eslint-disable-next-line unicorn/no-nested-ternary
      : activeVenueIndex !== -1
      ? venues[activeVenueIndex]
      : null
  const activeVenues = activeVenueOrNull ? [activeVenueOrNull] : venues

  // rooms

  const roomsOfActiveVenues = activeVenues.flatMap((venue) => venue.rooms)
  const [activeRoomIds, dispatchRooms] = useReducer(
    activeIdReducer,
    roomsOfActiveVenues.map((room) => room.id)
  )
  const activeRooms = roomsOfActiveVenues.filter((room) =>
    activeRoomIds.includes(room.id)
  )

  // events

  const events = wcif.events
  const [activeEventIds, dispatchEvents] = useReducer(
    activeIdReducer,
    events.map((event) => event.id)
  )

  // time zones

  const uniqueTimeZones = [...new Set(venues.map((venue) => venue.timezone))]
  const timeZoneCount = uniqueTimeZones.length

  // const { timeZone: userTimeZone } = Intl.DateTimeFormat().resolvedOptions()
  const activeTimeZone = activeVenues[0].timezone

  // TODO: if time zones are changeable, these may be wrong
  const activeDates = getDatesStartingOn(
    wcif.schedule.startDate,
    wcif.schedule.numberOfDays
  )

  return (
    <Segment padded attached>
      {timeZoneCount > 1 && (
        <Message warning>
          <Message.Content>
            Note that not all venues are in the same time zone -- please be
            careful!
          </Message.Content>
        </Message>
      )}

      <VenuesAndRooms
        venues={venues}
        activeVenueOrNull={activeVenueOrNull}
        activeVenueIndex={activeVenueIndex}
        setActiveVenueIndex={setActiveVenueIndex}
        timeZoneCount={timeZoneCount}
        rooms={roomsOfActiveVenues}
        activeRoomIds={activeRoomIds}
        dispatchRooms={dispatchRooms}
      />

      <EventsSelector
        events={events}
        activeEventIds={activeEventIds}
        dispatchEvents={dispatchEvents}
      />

      <TimeZoneSelector
        venues={venues}
        activeTimeZone={activeTimeZone}
        onSelect={() => 'TODO: handle time zone change'}
      />

      <ViewSelector selected={activeView} onSelect={setActiveView} />

      {activeView === 'calendar' ? (
        <CalendarView
          dates={activeDates}
          timeZone={activeTimeZone}
          venuesShown={activeVenues}
          events={wcif.events}
        />
      ) : (
        <TableView
          dates={activeDates}
          timeZone={activeTimeZone}
          rooms={activeRooms}
          events={wcif.events}
        />
      )}
    </Segment>
  )
}

function ViewSelector({ selected, onSelect }) {
  return (
    <Form>
      <Form.Field>
        <Checkbox
          radio
          label="Calendar View"
          name="viewGroup"
          value="calendar"
          checked={selected === 'calendar'}
          onChange={(_, data) => onSelect(data.value)}
        />
      </Form.Field>
      <Form.Field>
        <Checkbox
          radio
          label="Table View"
          name="viewGroup"
          value="table"
          checked={selected === 'table'}
          onChange={(_, data) => onSelect(data.value)}
        />
      </Form.Field>
    </Form>
  )
}

// TODO: refine logic
// TODO: clean up UI
function TimeZoneSelector({ venues, activeTimeZone, onSelect }) {
  const { timeZone: userTimeZone } = Intl.DateTimeFormat().resolvedOptions()
  const timeZoneOptions = [
    {
      key: 'local',
      text: `Local time zone: ${userTimeZone}`,
      value: userTimeZone,
    },
    ...venues.map((venue) => ({
      key: venue.name,
      text: `${venue.name}: ${venue.timezone}`,
      value: venue.timezone,
    })),
  ]
  return (
    <Dropdown
      placeholder="Time Zone"
      search
      selection
      value={activeTimeZone}
      onChange={onSelect}
      options={timeZoneOptions}
    />
  )
}

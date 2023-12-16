import React, { useMemo, useReducer, useState } from 'react'
import {
  Checkbox,
  Dropdown,
  Form,
  Message,
  Segment,
  Tab,
} from 'semantic-ui-react'
import { getDatesStartingOn } from '../../lib/dates'
import CalendarView from './CalendarView'
import TableView from './TableView'

const roomsReducer = (state, { type, id, ids }) => {
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

  const allVenues = wcif.schedule.venues
  const venueCount = allVenues.length
  const [activeVenueIndex, setActiveVenueIndex] = useState(-1)
  // the 1st tab is all venues combined
  const activeTabIndex = activeVenueIndex + 1
  const activeVenue =
    venueCount === 1
      ? allVenues[0] // eslint-disable-next-line unicorn/no-nested-ternary
      : activeVenueIndex !== -1
      ? allVenues[activeVenueIndex]
      : null
  const venuesShown = activeVenue ? [activeVenue] : allVenues

  // rooms

  const roomsShown = venuesShown.flatMap((venue) => venue.rooms)
  const [activeRoomIds, dispatchRooms] = useReducer(
    roomsReducer,
    roomsShown.map((room) => room.id)
  )
  const activeRooms = roomsShown.filter((room) =>
    activeRoomIds.includes(room.id)
  )

  // events

  // TODO: allow toggling events on/off

  // time zones

  const uniqueTimeZones = [...new Set(allVenues.map((venue) => venue.timezone))]
  const timeZoneCount = uniqueTimeZones.length

  // const { timeZone: userTimeZone } = Intl.DateTimeFormat().resolvedOptions()
  const activeTimeZone = venuesShown[0].timezone

  // TODO: if time zones are changeable, these may be wrong
  const activeDates = getDatesStartingOn(
    wcif.schedule.startDate,
    wcif.schedule.numberOfDays
  )

  // panes

  const panes = useMemo(
    () => [
      { menuItem: 'All Venues' },
      ...allVenues.map((venue) => ({ menuItem: venue.name })),
    ],
    [allVenues]
  )

  // TODO: move room selector into tabs to have fresh render?
  const handleTabChange = (newTabIndex) => {
    const newVenueIndex = newTabIndex - 1
    const newVenues =
      newVenueIndex > -1 ? [allVenues[newVenueIndex]] : allVenues

    setActiveVenueIndex(newVenueIndex)
    const ids = newVenues.flatMap((venue) => venue.rooms).map((room) => room.id)
    dispatchRooms({ type: 'reset', ids })
  }

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

      {venueCount > 1 && (
        <Tab
          menu={{ secondary: true, pointing: true }}
          panes={panes}
          activeIndex={activeTabIndex}
          onTabChange={(_, { activeIndex }) => handleTabChange(activeIndex)}
        />
      )}

      <TimeZoneSelector
        venues={allVenues}
        activeTimeZone={activeTimeZone}
        onSelect={() => 'TODO: handle time zone change'}
      />

      <VenueAndTimeZoneInfo
        activeVenue={activeVenue}
        venueCount={venueCount}
        activeTimeZone={activeTimeZone}
        timeZoneCount={timeZoneCount}
      />

      <RoomSelector
        allRooms={roomsShown}
        activeRoomIds={activeRoomIds}
        toggleRoom={(id) => dispatchRooms({ type: 'toggle', id })}
      />

      <ViewSelector selected={activeView} onSelect={setActiveView} />

      {activeView === 'calendar' ? (
        <CalendarView
          dates={activeDates}
          timeZone={activeTimeZone}
          venuesShown={venuesShown}
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

function VenueAndTimeZoneInfo({
  activeVenue,
  venueCount,
  activeTimeZone,
  timeZoneCount,
}) {
  const { timeZone: userTimeZone } = Intl.DateTimeFormat().resolvedOptions()
  const isUserTimeZone = activeTimeZone === userTimeZone
  const isVenueTimeZone = activeTimeZone === activeVenue?.timezone

  const mapLink =
    activeVenue &&
    `https://www.google.com/maps/place/${activeVenue.latitudeMicrodegrees},${activeVenue.longitudeMicrodegrees}`

  // TODO: add to calendar icon/functionality

  return (
    <>
      <Message>
        <Message.Content>
          {activeVenue ? (
            <>
              You are viewing the schedule for{' '}
              <a target="_blank" href={mapLink}>
                {activeVenue.name}
              </a>
              {venueCount === 1
                ? ', the sole venue for this competition.'
                : `, one of ${venueCount} venues for this competition.`}{' '}
              This venue is in the time zone {activeVenue.timezone}
              {venueCount > 1 && timeZoneCount === 1
                ? ', as are all other venues for this competition.'
                : '.'}{' '}
            </>
          ) : (
            <>You are viewing the schedule for all venues at once.</>
          )}{' '}
          The schedule is currently displayed in{' '}
          {isVenueTimeZone
            ? "the venue's timezone" // eslint-disable-next-line unicorn/no-nested-ternary
            : isUserTimeZone
            ? 'your timezone'
            : 'the time zone'}{' '}
          {activeTimeZone}.
        </Message.Content>
      </Message>
    </>
  )
}

// TODO: clean up UI
function RoomSelector({ allRooms, activeRoomIds, toggleRoom }) {
  return allRooms.map(({ id, name, color }) => (
    <Checkbox
      key={id}
      checked={activeRoomIds.includes(id)}
      label={name + ' (' + color + ')'}
      onChange={() => toggleRoom(id)}
    />
  ))
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

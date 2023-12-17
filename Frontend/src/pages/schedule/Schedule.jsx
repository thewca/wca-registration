import React, { useReducer, useState } from 'react'
import { Message, Segment } from 'semantic-ui-react'
import { getDatesStartingOn } from '../../lib/dates'
import CalendarView from './CalendarView'
import EventsSelector from './EventsSelector'
import TableView from './TableView'
import TimeZoneSelector from './TimeZone'
import VenuesAndRooms from './VenuesAndRooms'
import ViewSelector from './ViewSelector'

const { timeZone: userTimeZone } = Intl.DateTimeFormat().resolvedOptions()

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

const timeZoneReducer = (state, { type, venues, location, timeZone }) => {
  switch (type) {
    case 'update-location':
      if (venues && (location || location === 0)) {
        if (location === 'custom') {
          return { location, timeZone: state.timeZone }
        }
        const newTimeZone = getTimeZone(venues, location)
        if (newTimeZone) {
          return { location, timeZone: newTimeZone }
        }
        console.error('Must supply valid location.')
      } else {
        console.error('Must supply venues and location.')
      }
      break

    case 'update-time-zone':
      if (timeZone) {
        const newLocation = getLocation(venues, timeZone)
        return { location: newLocation, timeZone }
      }
      console.error('Must supply time zone.')
      break

    default:
      break
  }

  return state
}

const getTimeZone = (venues, location) => {
  if (Number.isInteger(location)) {
    return venues[location].timezone
  }
  if (location === 'local') {
    return userTimeZone
  }
  return undefined
}

const getLocation = (venues, timeZone) => {
  const matchingVenueIndex = venues.findIndex(
    (venue) => venue.timezone === timeZone
  )

  if (matchingVenueIndex !== -1) {
    return matchingVenueIndex
  }
  if (timeZone === userTimeZone) {
    return 'local'
  }
  return 'custom'
}

export default function Schedule({ wcif }) {
  // venues

  const venues = wcif.schedule.venues
  const mainVenueIndex = 0
  const venueCount = venues.length
  const [activeVenueIndex, setActiveVenueIndex] = useState(-1)
  const activeVenueOrNull =
    venueCount === 1
      ? venues[0] // eslint-disable-next-line unicorn/no-nested-ternary
      : activeVenueIndex !== -1
      ? venues[activeVenueIndex]
      : null
  const activeVenues = activeVenueOrNull ? [activeVenueOrNull] : venues

  const setActiveVenueIndexAndUpdateTimeZone = (newIndex) => {
    dispatchTimeZone({
      type: 'update-location',
      venues,
      location: newIndex === -1 ? mainVenueIndex : newIndex,
    })
    setActiveVenueIndex(newIndex)
  }

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

  const [
    { location: activeTimeZoneLocation, timeZone: activeTimeZone },
    dispatchTimeZone,
  ] = useReducer(timeZoneReducer, {
    location: mainVenueIndex,
    timeZone: venues[mainVenueIndex].timezone,
  })

  const uniqueTimeZones = [...new Set(venues.map((venue) => venue.timezone))]
  const timeZoneCount = uniqueTimeZones.length

  // view

  // TODO: save in local storage via new `useSavedState` hook
  const [activeView, setActiveView] = useState('calendar')

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
        setActiveVenueIndex={setActiveVenueIndexAndUpdateTimeZone}
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
        activeTimeZoneLocation={activeTimeZoneLocation}
        dispatchTimeZone={dispatchTimeZone}
      />

      <ViewSelector activeView={activeView} setActiveView={setActiveView} />

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

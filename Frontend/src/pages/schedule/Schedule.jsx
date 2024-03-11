import { EventSelector } from '@thewca/wca-components'
import React, { useReducer, useState } from 'react'
import { Message, Segment } from 'semantic-ui-react'
import { useStoredState } from '../../hooks/useStoredState'
import { earliestWithLongestTieBreaker } from '../../lib/activities'
import { getDatesBetweenInclusive } from '../../lib/dates'
import CalendarView from './CalendarView'
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
    (venue) => venue.timezone === timeZone,
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
    roomsOfActiveVenues.map((room) => room.id),
  )
  const activeRooms = roomsOfActiveVenues.filter((room) =>
    activeRoomIds.includes(room.id),
  )

  // events

  const events = wcif.events
  const [activeEventIds, dispatchEvents] = useReducer(
    activeIdReducer,
    events.map((event) => event.id),
  )
  const activeEvents = events.filter(({ id }) => activeEventIds.includes(id))

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

  const [activeView, setActiveView] = useStoredState('calendar', 'scheduleView')

  const allActivitiesSorted = venues
    .flatMap((venue) => venue.rooms)
    .flatMap((room) => room.activities)
    .toSorted(earliestWithLongestTieBreaker)
  // use this, rather than wcif's startDate, in-case viewing in different time zone
  const firstStartTime = allActivitiesSorted[0].startTime
  const lastStartTime =
    allActivitiesSorted[allActivitiesSorted.length - 1].startTime
  const activeDates = getDatesBetweenInclusive(
    firstStartTime,
    lastStartTime,
    activeTimeZone,
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

      <Message>
        <Message.Content>
          Schedules are subject to adjustments, especially once registration
          totals are known. Registered competitors will be notified by email of
          any major changes.
        </Message.Content>
      </Message>

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

      <Segment>
        <EventSelector
          events={events.map(({ id }) => id)}
          selected={activeEventIds}
          handleEventSelection={(ids) => dispatchEvents({ type: 'reset', ids })}
          size="2x"
        />
      </Segment>

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
          activeVenues={activeVenues}
          activeRooms={activeRooms}
          activeEvents={activeEvents}
        />
      ) : (
        <TableView
          dates={activeDates}
          timeZone={activeTimeZone}
          activeRooms={activeRooms}
          activeEvents={activeEvents}
          activeVenueOrNull={activeVenueOrNull}
        />
      )}
    </Segment>
  )
}

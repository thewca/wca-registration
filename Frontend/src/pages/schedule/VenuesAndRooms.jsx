import React from 'react'
import { Checkbox, Menu, Message } from 'semantic-ui-react'

export default function VenuesAndRooms({
  venues,
  activeVenueOrNull,
  activeVenueIndex,
  setActiveVenueIndex,
  timeZoneCount,
  rooms,
  activeRoomIds,
  dispatchRooms,
}) {
  const venueCount = venues.length

  const setActiveVenueIndexAndResetRooms = (newVenueIndex) => {
    const newVenues = newVenueIndex > -1 ? [venues[newVenueIndex]] : venues
    const ids = newVenues.flatMap((venue) => venue.rooms).map((room) => room.id)
    dispatchRooms({ type: 'reset', ids })

    setActiveVenueIndex(newVenueIndex)
  }

  // TODO: UI issues with lots of venues (FMC World) or small screens (phones)
  return (
    <>
      {venueCount > 1 && (
        <Menu pointing secondary fluid widths={venueCount + 1}>
          <Menu.Item
            name="All Venues"
            active={activeVenueIndex === -1}
            onClick={() => setActiveVenueIndexAndResetRooms(-1)}
          />
          {venues.map((venue, index) => (
            <Menu.Item
              key={venue.id}
              name={venue.name}
              active={index === activeVenueIndex}
              onClick={() => setActiveVenueIndexAndResetRooms(index)}
            />
          ))}
        </Menu>
      )}

      <VenueInfo
        activeVenueOrNull={activeVenueOrNull}
        venueCount={venueCount}
        timeZoneCount={timeZoneCount}
      />

      <RoomSelector
        rooms={rooms}
        activeRoomIds={activeRoomIds}
        toggleRoom={(id) => dispatchRooms({ type: 'toggle', id })}
      />
    </>
  )
}

// TODO: clean up UI
function RoomSelector({ rooms, activeRoomIds, toggleRoom }) {
  return rooms.map(({ id, name, color }) => (
    <Checkbox
      key={id}
      checked={activeRoomIds.includes(id)}
      label={name + ' (' + color + ')'}
      onChange={() => toggleRoom(id)}
    />
  ))
}

function VenueInfo({ activeVenueOrNull, venueCount, timeZoneCount }) {
  const { name, timezone } = activeVenueOrNull || {}
  // TODO: fix map link
  const mapLink =
    activeVenueOrNull &&
    `https://www.google.com/maps/place/${activeVenueOrNull.latitudeMicrodegrees},${activeVenueOrNull.longitudeMicrodegrees}`

  // TODO: add add-to-calendar icon/functionality

  return (
    <>
      <Message>
        <Message.Content>
          {activeVenueOrNull ? (
            <p>
              You are viewing the schedule for{' '}
              <a target="_blank" href={mapLink}>
                {name}
              </a>
              {venueCount === 1
                ? ', the sole venue for this competition.'
                : `, one of ${venueCount} venues for this competition.`}{' '}
              This venue is in the time zone {timezone}
              {venueCount > 1 && timeZoneCount === 1
                ? ', as are all other venues for this competition.'
                : '.'}
            </p>
          ) : (
            <p>
              You are viewing the schedule for all {venueCount} venues at once.
            </p>
          )}
        </Message.Content>
      </Message>
    </>
  )
}

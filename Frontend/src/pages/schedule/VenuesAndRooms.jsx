import React, { useMemo } from 'react'
import { Checkbox, Message, Tab } from 'semantic-ui-react'

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
  // the 1st tab is all venues combined
  const activeTabIndex = activeVenueIndex + 1
  const venueCount = venues.length

  const panes = useMemo(
    () => [
      { menuItem: 'All Venues' },
      ...venues.map((venue) => ({ menuItem: venue.name })),
    ],
    [venues]
  )

  // TODO: move room selector into tabs to have fresh render?
  const handleTabChange = (newTabIndex) => {
    const newVenueIndex = newTabIndex - 1
    const newVenues = newVenueIndex > -1 ? [venues[newVenueIndex]] : venues

    setActiveVenueIndex(newVenueIndex)
    const ids = newVenues.flatMap((venue) => venue.rooms).map((room) => room.id)
    dispatchRooms({ type: 'reset', ids })
  }

  return (
    <>
      {venueCount > 1 && (
        // TODO: should be menu, not tabs (or something else, like a dropdown)
        <Tab
          menu={{ secondary: true, pointing: true }}
          panes={panes}
          activeIndex={activeTabIndex}
          onTabChange={(_, { activeIndex }) => handleTabChange(activeIndex)}
        />
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

import React, { useMemo } from 'react'
import { Checkbox, Tab } from 'semantic-ui-react'

export default function VenuesAndRooms({
  venues,
  activeVenueIndex,
  setActiveVenueIndex,
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
        <Tab
          menu={{ secondary: true, pointing: true }}
          panes={panes}
          activeIndex={activeTabIndex}
          onTabChange={(_, { activeIndex }) => handleTabChange(activeIndex)}
        />
      )}

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

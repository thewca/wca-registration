import React from 'react'
import { Dropdown } from 'semantic-ui-react'

// TODO: refine logic
// TODO: clean up UI
export default function TimeZoneSelector({
  venues,
  activeTimeZone,
  dispatchTimeZone,
}) {
  const { timeZone: userTimeZone } = Intl.DateTimeFormat().resolvedOptions()
  const timeZoneOptions = [
    {
      key: 'local',
      text: `Your time zone: ${userTimeZone}`,
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
      search
      selection
      value={activeTimeZone}
      onChange={(_, data) =>
        dispatchTimeZone({ action: 'update', timeZone: data.value })
      }
      options={timeZoneOptions}
    />
  )
}

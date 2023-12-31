import { UiIcon } from '@thewca/wca-components'
import { DateTime } from 'luxon'
import React from 'react'

export default function AddToCalendar({ startDate, endDate, name, address }) {
  const formattedStartDate = DateTime.fromISO(startDate).toFormat('yyyyMMdd')
  // note: date corresponds to midnight for all-day events, so need to use the day after
  const formattedEndDate = DateTime.fromISO(endDate)
    .plus({ days: 1 })
    .toFormat('yyyyMMdd')
  const googleCalendarLink = `https://calendar.google.com/calendar/render?action=TEMPLATE&text=${name}&dates=${formattedStartDate}/${formattedEndDate}&location=${address}`

  return (
    <a href={googleCalendarLink} target="_blank">
      <UiIcon name="calendar plus" />
    </a>
  )
}

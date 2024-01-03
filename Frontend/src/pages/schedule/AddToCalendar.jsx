import { UiIcon } from '@thewca/wca-components'
import { DateTime } from 'luxon'
import React from 'react'

export default function AddToCalendar({
  startDate,
  endDate,
  name,
  address,
  allDay,
}) {
  // note: date corresponds to midnight for all-day events, so need to use the day after
  const endDateOffset = allDay ? { days: 1 } : {}
  const format = allDay ? 'yyyyMMdd' : "yyyyMMdd'T'HHmmssZ"

  const formattedStartDate = DateTime.fromISO(startDate).toFormat(format)
  const formattedEndDate = DateTime.fromISO(endDate)
    .plus(endDateOffset)
    .toFormat(format)

  const googleCalendarLink = `https://calendar.google.com/calendar/render?action=TEMPLATE&text=${name}&dates=${formattedStartDate}/${formattedEndDate}${
    address ? `&location=${address}` : ''
  }`

  return (
    <a href={googleCalendarLink} target="_blank">
      <UiIcon name="calendar plus" />
    </a>
  )
}

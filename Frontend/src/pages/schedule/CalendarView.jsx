import luxonPlugin from '@fullcalendar/luxon3'
import FullCalendar from '@fullcalendar/react'
import timeGridPlugin from '@fullcalendar/timegrid'
import { DateTime } from 'luxon'
import React from 'react'
import {
  earliestTimeOfDayWithBuffer,
  getActivityEvent,
  latestTimeOfDayWithBuffer,
} from '../../lib/activities'
import { getTextColor } from '../../lib/colors'

// based on monolith code: https://github.com/thewca/worldcubeassociation.org/blob/0882a86cf5d83c3a0dbc667a59be05ce8845c3e4/WcaOnRails/app/webpacker/components/EditSchedule/EditActivities/index.js

// TODO: add tooltip or popup on events for more details
// TODO: set calendar's locale
// TODO: table has 24h, calendar has 12h - make consistent (fixed by setting locale?)
// TODO: indicate that event split across days are such?
// TODO: add add-to-calendar functionality?

export default function CalendarView({
  dates,
  timeZone,
  activeVenues,
  activeRooms,
  activeEvents,
}) {
  const activeEventIds = activeEvents.map(({ id }) => id)
  const fcActivities = activeRooms.flatMap((room) =>
    room.activities
      .filter((activity) =>
        ['other', ...activeEventIds].includes(getActivityEvent(activity))
      )
      .map((activity) => ({
        title: activity.name,
        start: activity.startTime,
        end: activity.endTime,
        backgroundColor: room.color,
        textColor: getTextColor(room.color),
      }))
  )

  // independent of which activities are visible,
  // to prevent calendar height jumping around
  const activeVenuesActivities = activeVenues.flatMap((venue) =>
    venue.rooms.flatMap((room) => room.activities)
  )
  const calendarStart =
    earliestTimeOfDayWithBuffer(activeVenuesActivities, timeZone) ?? '00:00:00'
  const calendarEnd =
    latestTimeOfDayWithBuffer(activeVenuesActivities, timeZone) ?? '00:00:00'

  const onEventClick = () => {
    /* TODO */
  }

  return (
    <>
      <FullCalendar
        // plugins for the basic FullCalendar implementation.
        //   - timeGridPlugin: Display days as vertical grid
        //   - luxonPlugin: Support timezones
        plugins={[timeGridPlugin, luxonPlugin]}
        // define our "own" view
        initialView="agendaForComp"
        views={{
          agendaForComp: {
            type: 'timeGrid',
            // specify start/end rather than duration/initialDate, since
            // dates may change when changing time zone
            visibleRange: {
              start: dates[0].toJSDate(),
              end: dates[dates.length - 1].toJSDate(),
            },
          },
        }}
        // by default, FC offers support for separate "whole-day" events
        allDaySlot={false}
        // by default, FC would show a "skip to next day" toolbar
        headerToolbar={false}
        dayHeaderFormat={DateTime.DATE_HUGE}
        slotMinTime={calendarStart}
        slotMaxTime={calendarEnd}
        slotDuration="00:30:00"
        height="auto"
        // localization settings
        // TODO get locale
        // locale={calendarLocale}
        timeZone={timeZone}
        events={fcActivities}
        eventClick={onEventClick}
      />
      {fcActivities.length === 0 && (
        <em>No activities for the selected rooms/events.</em>
      )}
    </>
  )
}

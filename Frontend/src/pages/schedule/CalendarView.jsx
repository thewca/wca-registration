import FullCalendar from '@fullcalendar/react'
import timeGridPlugin from '@fullcalendar/timegrid'
import luxonPlugin from '@fullcalendar/luxon3'
import React from 'react'
import { getActivityEvent } from '../../lib/activities'
import { getTextColor } from '../../lib/colors'

// based on monolith code: https://github.com/thewca/worldcubeassociation.org/blob/0882a86cf5d83c3a0dbc667a59be05ce8845c3e4/WcaOnRails/app/webpacker/components/EditSchedule/EditActivities/index.js

// TODO: start and end times
// TODO: make column date consistent with table view dates
// TODO: add tooltip or popup on events for more details
// TODO: initialDate change doesn't update calendar
// > can set explicit range, see https://fullcalendar.io/docs/visibleRange
// TODO: set calendar's locale
// TODO: table has 24h, calendar has 12h - make consistent (fixed by setting locale?)
// TODO: indicate that event split across days are such?
// TODO: add add-to-calendar functionality?

export default function CalendarView({
  dates,
  timeZone,
  activeRooms,
  activeEvents,
}) {
  const eventIds = activeEvents.map(({ id }) => id)
  const fcActivities = activeRooms.flatMap((room) =>
    room.activities
      .filter((activity) =>
        ['other', ...eventIds].includes(getActivityEvent(activity))
      )
      .map((activity) => ({
        title: activity.name,
        start: activity.startTime,
        end: activity.endTime,
        backgroundColor: room.color,
        textColor: getTextColor(room.color),
      }))
  )

  const onEventClick = () => {
    /* TODO */
  }

  return (
    <FullCalendar
      // plugins for the basic FullCalendar implementation.
      //   - timeGridPlugin: Display days as vertical grid
      //   - luxonPlugin: Support timezones
      plugins={[timeGridPlugin, luxonPlugin]}
      // define our "own" view (which is basically just saying how many days we want)
      initialView="agendaForComp"
      views={{
        agendaForComp: {
          type: 'timeGrid',
          duration: { days: dates.length },
        },
      }}
      initialDate={dates[0]}
      // by default, FC offers support for separate "whole-day" events
      allDaySlot={false} // ? required?
      // by default, FC would show a "skip to next day" toolbar
      headerToolbar={false}
      slotMinTime="00:00:00" // ! adjust
      slotMaxTime="24:00:00" // ! adjust
      slotDuration="00:30:00"
      height="auto"
      // localization settings
      // TODO get locale
      // locale={calendarLocale}
      timeZone={timeZone}
      events={fcActivities}
      eventClick={onEventClick}
    />
  )
}

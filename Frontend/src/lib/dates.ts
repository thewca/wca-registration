import { Activity } from '@wca/helpers'
import { DateTime } from 'luxon'

// start/end dates may have different time-of-days
export const getDatesBetweenInclusive = (
  startDate: string,
  endDate: string,
  timeZone: string
) => {
  // avoid infinite loop on invalid params
  if (startDate > endDate) return []

  const dates: Date[] = []
  let nextDate = new Date(startDate)
  while (!areOnSameDate(nextDate, new Date(endDate), timeZone)) {
    dates.push(nextDate)
    nextDate = new Date(nextDate)
    nextDate.setDate(nextDate.getDate() + 1)
  }
  dates.push(nextDate)
  return dates
}

export const areOnSameDate = (date1: Date, date2: Date, timeZone: string) => {
  // Not sure how to check 2 dates are the same **in a specific time zone**,
  // besides printing them as strings (which feels wrong).
  // (There's only .getDay() for local time zone and .getUTCDay() for UTC,
  // but no such function for an arbitrary time zone.)
  return (
    date1.toLocaleDateString([], { timeZone }) ===
    date2.toLocaleDateString([], { timeZone })
  )
}

export function isAfterNow(date: string): boolean {
  return DateTime.fromISO(date) > DateTime.now()
}

export const activitiesByDate = (
  activities: Activity[],
  date: Date,
  timeZone: string
) => {
  return activities.filter((activity) =>
    areOnSameDate(new Date(activity.startTime), date, timeZone)
  )
}

export const getShortTime = (date: string, timeZone: string) => {
  return new Date(date).toLocaleTimeString([], {
    timeStyle: 'short',
    timeZone,
  })
}

export const getMediumDate = (date: string) => {
  return DateTime.fromISO(date).toLocaleString(DateTime.DATE_MED)
}

export const getLongDate = (date: string, timeZone: string) => {
  return new Date(date).toLocaleDateString([], {
    weekday: 'long',
    year: 'numeric',
    month: 'long',
    day: 'numeric',
    timeZone,
  })
}

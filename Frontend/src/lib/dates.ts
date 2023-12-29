import { Activity } from '@wca/helpers'
import { DateTime } from 'luxon'

export const getDatesStartingOn = (
  startDate: string,
  numberOfDays: number,
  options?: { offset: number }
): Date[] => {
  const { offset } = options || { offset: 0 }
  const range = []
  for (let i = offset; i < numberOfDays + offset; i++) {
    range.push(DateTime.fromISO(startDate).plus({ days: i }).toJSDate())
  }
  return range
}

export function isAfterNow(date: string): boolean {
  return DateTime.fromISO(date) > DateTime.now()
}

export const activitiesByDate = (
  activities: Activity[],
  date: Date,
  timeZone: string
) => {
  return activities.filter(
    // not sure how to check startTime *in timeZone* is on date, besides
    // comparing locale strings, which seems bad
    // (there's only .getDay() for local time zone and .getUTCDay() for UTC,
    // but no such function for arbitrary time zone)
    (activity) =>
      new Date(activity.startTime).toLocaleDateString([], { timeZone }) ===
      date.toLocaleDateString()
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

export const getLongDate = (date: string) => {
  return new Date(date).toLocaleDateString([], {
    weekday: 'long',
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  })
}

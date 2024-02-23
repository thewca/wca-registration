import { DateTime } from 'luxon'

// parameter name conventions:
// - `luxonDate` for luxon DateTime objects
// - `date` for date-only ISO strings (no time)
// - `dateTime` for date-and-time ISO strings

//// luxon parameters

export const areOnSameDate = (
  luxonDate1: DateTime,
  luxonDate2: DateTime,
  timeZone: string,
) => {
  return luxonDate1
    .setZone(timeZone)
    .hasSame(luxonDate2.setZone(timeZone), 'day')
}

export const roundBackToHour = (luxonDate: DateTime) => {
  return luxonDate.set({ minute: 0, second: 0, millisecond: 0 })
}

export const addEndBufferWithinDay = (luxonDate: DateTime) => {
  const buffered = luxonDate.plus({ minutes: 10 })
  if (buffered.day !== luxonDate.day) {
    return luxonDate
  }
  return buffered
}

//// string parameters

export function hasPassed(dateTime: string): boolean {
  return DateTime.fromISO(dateTime) < DateTime.now()
}

export function hasNotPassed(dateTime: string): boolean {
  return DateTime.now() < DateTime.fromISO(dateTime)
}

export const doesRangeCrossMidnight = (
  startDateTime: string,
  endDateTime: string,
  timeZone: string,
) => {
  const luxonStart = DateTime.fromISO(startDateTime)
  const luxonEnd = DateTime.fromISO(endDateTime)
  return !areOnSameDate(luxonStart, luxonEnd, timeZone)
}

export const getShortTimeString = (dateTime: string, timeZone = 'local') => {
  return DateTime.fromISO(dateTime)
    .setZone(timeZone)
    .toLocaleString(DateTime.TIME_SIMPLE)
}

// note: some uses are passing dates with times or dates without times
// ie: `event_change_deadline_date ?? competitionInfo.start_date`
export const getMediumDateString = (dateTime: string, timeZone = 'local') => {
  return DateTime.fromISO(dateTime)
    .setZone(timeZone)
    .toLocaleString(DateTime.DATE_MED)
}

export const getLongDateString = (dateTime: string, timeZone = 'local') => {
  return DateTime.fromISO(dateTime)
    .setZone(timeZone)
    .toLocaleString(DateTime.DATE_HUGE)
}

export const getFullDateTimeString = (dateTime: string, timeZone = 'local') => {
  return DateTime.fromISO(dateTime)
    .setZone(timeZone)
    .toLocaleString(DateTime.DATETIME_FULL_WITH_SECONDS)
}

// start/end dates may have different time-of-days
export const getDatesBetweenInclusive = (
  startDateTime: string,
  endDateTime: string,
  timeZone: string,
) => {
  // avoid infinite loop on invalid params
  if (startDateTime > endDateTime) return []

  const luxonStart = DateTime.fromISO(startDateTime).setZone(timeZone)
  const luxonEnd = DateTime.fromISO(endDateTime).setZone(timeZone)

  const datesBetween: DateTime[] = []
  let nextDate = luxonStart
  while (!areOnSameDate(nextDate, luxonEnd, timeZone)) {
    datesBetween.push(nextDate)
    nextDate = nextDate.plus({ days: 1 })
  }
  datesBetween.push(nextDate)
  return datesBetween
}

// luxon does not support time-only object, so use today's date in utc
export const todayWithTime = (dateTime: string, timeZone: string) => {
  const luxonDate = DateTime.fromISO(dateTime).setZone(timeZone)
  return DateTime.utc().set({
    hour: luxonDate.hour,
    minute: luxonDate.minute,
    second: luxonDate.second,
    millisecond: luxonDate.millisecond,
  })
}

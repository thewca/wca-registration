import moment from 'moment'

export const getDatesStartingOn = (startDate, numberOfDays, options) => {
  const { offset } = options || { offset: 0 }
  const range = []
  for (let i = offset; i < numberOfDays + offset; i++) {
    range.push(moment(startDate).add(i, 'days').toDate())
  }
  return range
}

export const activitiesByDate = (activities, date, timeZone) => {
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

export const getShortTime = (date, timeZone) => {
  return new Date(date).toLocaleTimeString([], {
    timeStyle: 'short',
    timeZone,
  })
}

export const getLongDate = (date) => {
  return new Date(date).toLocaleDateString([], {
    weekday: 'long',
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  })
}

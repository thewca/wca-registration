import { DateTime } from 'luxon'

export function dateFromNow(months: number, days = 0) {
  return DateTime.now()
    .plus({ months, days })
    .set({ hour: 19, minute: 0, second: 0, millisecond: 0 })
    .toISO()
}

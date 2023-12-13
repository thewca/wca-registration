import moment from 'moment/moment'

export function dateFromNow(months: number, days = 0) {
  return moment()
    .add(months, 'months')
    .add(days, 'days')
    .set({ hour: 19, minute: 0, second: 0, millisecond: 0 })
    .toISOString()
}

import { EventId, getEventResultType } from '@wca/helpers'

export const SECOND_IN_CS = 100
export const MINUTE_IN_CS = 60 * SECOND_IN_CS
export const HOUR_IN_CS = 60 * MINUTE_IN_CS

interface PluralizeParams {
  count: number
  word: string
  options?: {
    fixed?: number
    abbreviate?: boolean
  }
}

export function pluralize({ count, word, options = {} }: PluralizeParams) {
  const countStr =
    options.fixed && count % 1 > 0 ? count.toFixed(options.fixed) : count
  const countDesc = options.abbreviate
    ? word[0]
    : ` ${count === 1 ? word : `${word}s`}`
  return countStr + countDesc
}

interface AttemptResultToStringParams {
  attemptResult: number
  eventId: EventId
}

export function attemptResultToString({
  attemptResult,
  eventId,
}: AttemptResultToStringParams) {
  const type = getEventResultType(eventId)
  if (type === 'time') {
    return centiSecondsToHumanReadable({ c: attemptResult })
  }
  if (type === 'number') {
    return `${attemptResult} moves`
  }
  return `${attemptResultToMbPoints(attemptResult)} points`
}

function parseMbValue(val: number) {
  let mbValue = val
  const old = Math.floor(mbValue / 1000000000) !== 0
  let timeSeconds
  let attempted
  let solved
  if (old) {
    timeSeconds = mbValue % 100000
    mbValue = Math.floor(mbValue / 100000)
    attempted = mbValue % 100
    mbValue = Math.floor(mbValue / 100)
    solved = 99 - (mbValue % 100)
  } else {
    const missed = mbValue % 100
    mbValue = Math.floor(mbValue / 100)
    timeSeconds = mbValue % 100000
    mbValue = Math.floor(mbValue / 100000)
    const difference = 99 - (mbValue % 100)

    solved = difference + missed
    attempted = solved + missed
  }

  const timeCentiseconds = timeSeconds === 99999 ? null : timeSeconds * 100
  return { solved, attempted, timeCentiseconds }
}

function attemptResultToMbPoints(mbValue: number) {
  const { solved, attempted } = parseMbValue(mbValue)
  const missed = attempted - solved
  return solved - missed
}

interface CentiSecondsToHumanReadableParams {
  c: number
  options?: {
    short?: boolean
  }
}
export function centiSecondsToHumanReadable({
  c,
  options = {},
}: CentiSecondsToHumanReadableParams) {
  let centiseconds = c
  let str = ''

  const hours = centiseconds / HOUR_IN_CS
  centiseconds %= HOUR_IN_CS
  if (hours >= 1) {
    str += `${pluralize({
      count: Math.floor(hours),
      word: 'hour',
      options: { abbreviate: options.short },
    })} `
  }

  const minutes = centiseconds / MINUTE_IN_CS
  centiseconds %= MINUTE_IN_CS
  if (minutes >= 1) {
    str += `${pluralize({
      count: Math.floor(minutes),
      word: 'minute',
      options: { abbreviate: options.short },
    })} `
  }

  const seconds = centiseconds / SECOND_IN_CS
  if (seconds > 0 || str.length === 0) {
    str += `${pluralize({
      count: seconds,
      word: 'second',
      options: { fixed: 2, abbreviate: options.short },
    })} `
  }

  return str.trim()
}

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

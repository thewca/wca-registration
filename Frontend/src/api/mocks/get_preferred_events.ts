import { EventId } from '@wca/helpers'

export function getPreferredEventsMock(): EventId[] {
  const events = [
    '222',
    '333',
    '444',
    '555',
    '666',
    '777',
    '333bf',
    '333fm',
    '333oh',
    'clock',
    'minx',
    'pyram',
    'skewb',
    'sq1',
    '444bf',
    '555bf',
    '333mbf',
  ]
  const end = Math.round(Math.random() * events.length)
  const start = Math.round(Math.random() * end)
  return events.slice(start, end) as EventId[]
}

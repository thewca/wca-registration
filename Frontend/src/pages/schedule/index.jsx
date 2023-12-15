import { useQuery } from '@tanstack/react-query'
import React, { useContext, useMemo, useState } from 'react'
import {
  Checkbox,
  Dropdown,
  Form,
  Message,
  Segment,
  Tab,
} from 'semantic-ui-react'
import getCompetitionWcif from '../../api/competition/get/get_competition_wcif'
import { CompetitionContext } from '../../api/helper/context/competition_context'
import { getDatesStartingOn } from '../../lib/dates'
import { setMessage } from '../../ui/events/messages'
import LoadingMessage from '../../ui/messages/loadingMessage'
import TableView from './TableView'
import CalendarView from './CalendarView'

export default function Schedule() {
  const { competitionInfo } = useContext(CompetitionContext)

  const {
    isLoading,
    isError,
    data: wcif,
  } = useQuery({
    queryKey: ['wcif', competitionInfo.id],
    queryFn: () => getCompetitionWcif(competitionInfo.id),
    retry: false,
    onError: (err) => setMessage(err.message, 'error'),
  })

  const [activeView, setActiveView] = useState('calendar')

  const allVenues = wcif?.schedule?.venues
  const venueCount = allVenues?.length
  const [activeVenueIndex, setActiveVenueIndex] = useState(-1)
  // the 1st tab is all venues combined
  const activeTabIndex = activeVenueIndex + 1
  const activeVenue =
    venueCount === 1
      ? allVenues[0]
      : activeVenueIndex !== -1 // eslint-disable-next-line unicorn/no-nested-ternary
      ? wcif?.schedule?.venues[activeVenueIndex]
      : null
  const venuesShown = activeVenue ? [activeVenue] : allVenues

  // TODO: allow toggling events on/off

  const uniqueTimeZones = [
    ...new Set(allVenues?.map((venue) => venue.timezone)),
  ]
  const timeZoneCount = uniqueTimeZones.length

  const { timeZone: userTimeZone } = Intl.DateTimeFormat().resolvedOptions()
  const activeTimeZone = activeVenue?.timezone ?? userTimeZone

  // TODO: if time zones are changeable, these may be wrong
  const activeDates = wcif
    ? getDatesStartingOn(wcif.schedule.startDate, wcif.schedule.numberOfDays)
    : []

  const panes = useMemo(
    () => [
      { menuItem: 'All Venues' },
      ...(wcif?.schedule?.venues?.map((venue) => ({
        menuItem: venue.name,
      })) ?? []),
    ],
    [wcif?.schedule?.venues]
  )

  if (isLoading) {
    return <LoadingMessage />
  }

  if (isError) {
    return <Message>Loading the schedule failed, please try again.</Message>
  }

  return (
    <Segment padded attached>
      {timeZoneCount > 1 && (
        <Message warning>
          <Message.Content>
            Note that not all venues are in the same time zone -- please be
            careful!
          </Message.Content>
        </Message>
      )}

      {venueCount > 1 && (
        <Tab
          menu={{ secondary: true, pointing: true }}
          panes={panes}
          activeIndex={activeTabIndex}
          onTabChange={(_, { activeIndex }) =>
            setActiveVenueIndex(activeIndex - 1)
          }
        />
      )}

      <ViewSelector selected={activeView} onSelect={setActiveView} />

      <TimeZoneSelector
        venues={allVenues}
        activeTimeZone={activeTimeZone}
        onSelect={() => 'TODO: handle time zone change'}
      />

      <VenueAndTimeZoneInfo
        activeVenue={activeVenue}
        venueCount={venueCount}
        activeTimeZone={activeTimeZone}
        timeZoneCount={timeZoneCount}
      />

      {activeView === 'calendar' ? (
        <CalendarView
          dates={activeDates}
          timeZone={activeTimeZone}
          venuesShown={venuesShown}
          events={wcif.events}
        />
      ) : (
        <TableView
          dates={activeDates}
          timeZone={activeTimeZone}
          venuesShown={venuesShown}
          events={wcif.events}
        />
      )}
    </Segment>
  )
}

function VenueAndTimeZoneInfo({
  activeVenue,
  venueCount,
  activeTimeZone,
  timeZoneCount,
}) {
  const { timeZone: userTimeZone } = Intl.DateTimeFormat().resolvedOptions()
  const isUserTimeZone = activeTimeZone === userTimeZone
  const isVenueTimeZone = activeTimeZone === activeVenue?.timezone

  const mapLink =
    activeVenue &&
    `https://www.google.com/maps/place/${activeVenue.latitudeMicrodegrees},${activeVenue.longitudeMicrodegrees}`

  // TODO: add to calendar icon/functionality

  return (
    <>
      <Message>
        <Message.Content>
          {activeVenue ? (
            <>
              You are viewing the schedule for{' '}
              <a target="_blank" href={mapLink}>
                {activeVenue.name}
              </a>
              {venueCount === 1
                ? ', the sole venue for this competition.'
                : `, one of ${venueCount} venues for this competition.`}{' '}
              This venue is in the time zone {activeVenue.timezone}
              {venueCount > 1 && timeZoneCount === 1
                ? ', as are all other venues for this competition.'
                : '.'}{' '}
            </>
          ) : (
            <>You are viewing the schedule for all venues at once.</>
          )}{' '}
          The schedule is currently displayed in{' '}
          {isVenueTimeZone
            ? "the venue's timezone"
            : isUserTimeZone // eslint-disable-next-line unicorn/no-nested-ternary
            ? 'your timezone'
            : 'the time zone'}{' '}
          {activeTimeZone}.
        </Message.Content>
      </Message>
    </>
  )
}

function ViewSelector({ selected, onSelect }) {
  return (
    <Form>
      <Form.Field>
        <Checkbox
          radio
          label="Calendar View"
          name="viewGroup"
          value="calendar"
          checked={selected === 'calendar'}
          onChange={(_, data) => onSelect(data.value)}
        />
      </Form.Field>
      <Form.Field>
        <Checkbox
          radio
          label="Table View"
          name="viewGroup"
          value="table"
          checked={selected === 'table'}
          onChange={(_, data) => onSelect(data.value)}
        />
      </Form.Field>
    </Form>
  )
}

// TODO: refine logic
// TODO: clean up UI
function TimeZoneSelector({ venues, activeTimeZone, onSelect }) {
  const { timeZone: userTimeZone } = Intl.DateTimeFormat().resolvedOptions()
  const timeZoneOptions = [
    {
      key: 'local',
      text: `Local time zone: ${userTimeZone}`,
      value: userTimeZone,
    },
    ...venues.map((venue) => ({
      key: venue.name,
      text: `${venue.name}: ${venue.timezone}`,
      value: venue.timezone,
    })),
  ]
  return (
    <Dropdown
      placeholder="Time Zone"
      search
      selection
      value={activeTimeZone}
      onChange={onSelect}
      options={timeZoneOptions}
    />
  )
}

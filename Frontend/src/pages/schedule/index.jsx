import { useQuery } from '@tanstack/react-query'
import React, { useContext, useMemo, useState } from 'react'
import { Message, Segment, Tab } from 'semantic-ui-react'
import getCompetitionWcif from '../../api/competition/get/get_competition_wcif'
import { CompetitionContext } from '../../api/helper/context/competition_context'
import { setMessage } from '../../ui/events/messages'
import LoadingMessage from '../../ui/messages/loadingMessage'
import TableView from './TableView'

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

  const [activeVenueIndex, setActiveVenueIndex] = useState(-1)
  // the 1st tab is all venues combined
  const activeTabIndex = activeVenueIndex + 1
  const activeVenue =
    activeVenueIndex !== -1 ? wcif?.schedule?.venues[activeVenueIndex] : null
  const allVenues = wcif?.schedule?.venues
  const venueCount = allVenues?.length

  // TODO: allow changing time zone
  // TODO: allow toggling rooms on/off
  // TODO: allow toggling events on/off

  const { timeZone: userTimeZone } = Intl.DateTimeFormat().resolvedOptions()
  const timeZone = activeVenue?.timezone ?? userTimeZone

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

      <VenueAndTimeZoneInfo
        activeVenue={activeVenue}
        venueCount={venueCount}
        timeZone={timeZone}
      />

      {/* TODO: calendar view option */}
      <TableView
        timeZone={timeZone}
        wcifSchedule={wcif.schedule}
        venuesShown={activeVenue ? [activeVenue] : allVenues}
        events={wcif.events}
      />
    </Segment>
  )
}

function VenueAndTimeZoneInfo({ activeVenue, venueCount, timeZone }) {
  const { timeZone: userTimeZone } = Intl.DateTimeFormat().resolvedOptions()
  const timeZoneWithFallback = timeZone || userTimeZone
  const isUserTimeZone = timeZoneWithFallback === userTimeZone
  const isVenueTimeZone = timeZoneWithFallback === activeVenue?.timezone
  const mapLink =
    activeVenue &&
    `https://www.google.com/maps/place/${activeVenue.latitudeMicrodegrees},${activeVenue.longitudeMicrodegrees}`

  // TODO: add to calendar icon/functionality

  return (
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
            This venue is in the time zone {activeVenue.timezone}.
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
        {timeZoneWithFallback}.
      </Message.Content>
    </Message>
  )
}

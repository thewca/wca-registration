import { useQuery } from '@tanstack/react-query'
import { getFormatName } from '@wca/helpers'
import moment from 'moment'
import React, { useContext, useMemo } from 'react'
import {
  Header,
  Message,
  Segment,
  Tab,
  Table,
  TableCell,
} from 'semantic-ui-react'
import getCompetitionWcif from '../../api/competition/get/get_competition_wcif'
import { CompetitionContext } from '../../api/helper/context/competition_context'
import { setMessage } from '../../ui/events/messages'
import LoadingMessage from '../../ui/messages/loadingMessage'

const getDatesStartingOn = (startDate, numberOfDays) => {
  const range = []
  for (let i = 0; i < numberOfDays; i++) {
    range.push(moment(startDate).add(i, 'days').toDate())
  }
  return range
}

const activitiesByDate = (activities, date, timeZone) => {
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

const getShortTime = (date, timeZone) => {
  return new Date(date).toLocaleTimeString([], {
    timeStyle: 'short',
    timeZone,
  })
}

const getLongDate = (date) => {
  return new Date(date).toLocaleDateString([], {
    weekday: 'long',
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  })
}

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

  const venueCount = wcif?.schedule?.venues?.length

  const panes = useMemo(
    () =>
      wcif?.schedule?.venues?.map((venue) => ({
        menuItem: venue.name,
        render: () => (
          <VenueSchedule
            schedule={wcif.schedule}
            venue={venue}
            events={wcif.events}
          />
        ),
      })) ?? [],
    [wcif?.schedule, wcif?.events]
  )

  if (isLoading) {
    return <LoadingMessage />
  }

  if (isError) {
    return <Message>Loading the schedule failed, please try again.</Message>
  }

  return (
    <Segment padded attached>
      {venueCount === 1 ? (
        <VenueSchedule
          schedule={wcif.schedule}
          venue={wcif.schedule.venues[0]}
          events={wcif.events}
        />
      ) : (
        <Tab menu={{ secondary: true, pointing: true }} panes={panes} />
      )}
    </Segment>
  )
}

function VenueSchedule({ schedule, venue, events }) {
  const venueCount = schedule.venues.length
  const mapLink = `https://www.google.com/maps/place/${venue.latitudeMicrodegrees},${venue.longitudeMicrodegrees}`
  const timeZone = venue.timezone

  return (
    <>
      <Message>
        <Message.Content>
          You are viewing the schedule for{' '}
          <a target="_blank" href={mapLink}>
            {venue.name}
          </a>
          {venueCount === 1
            ? ', the sole venue for this competition.'
            : `, one of ${venueCount} venues for this competition.`}{' '}
          This schedule is displayed in the venue's time zone: {timeZone}.
        </Message.Content>
      </Message>

      {getDatesStartingOn(schedule.startDate, schedule.numberOfDays).map(
        (date) => {
          const title = `Schedule for ${getLongDate(date)}`
          const activitiesForDay = activitiesByDate(
            venue.rooms.flatMap((room) => room.activities),
            date,
            timeZone
          )
          const rounds = events.flatMap((events) => events.rounds)

          return (
            <Segment key={date.getDate()} basic>
              <Header as="h2">{title}</Header>
              <OneDayTable
                activities={activitiesForDay}
                rounds={rounds}
                venue={venue}
              />
            </Segment>
          )
        }
      )}
    </>
  )
}

function OneDayTable({ activities, venue, rounds }) {
  const sortedActivities = [...activities].sort(compareActivities)

  return (
    <Table striped>
      <HeaderRow />
      <Table.Body>
        {sortedActivities.map((activity) => {
          const round = rounds.find(
            (round) => round.id === activity.activityCode
          )
          const room = venue.rooms.find((room) =>
            room.activities.some(
              (ac) => ac.activityCode === activity.activityCode
            )
          )

          return (
            <ActivityRow
              key={activity.id}
              activity={activity}
              venue={venue}
              round={round}
              room={room}
            />
          )
        })}
      </Table.Body>
    </Table>
  )
}

function HeaderRow() {
  return (
    <Table.Header>
      <Table.Row>
        <Table.HeaderCell>Start</Table.HeaderCell>
        <Table.HeaderCell>End</Table.HeaderCell>
        <Table.HeaderCell>Activity</Table.HeaderCell>
        <Table.HeaderCell>Room</Table.HeaderCell>
        <Table.HeaderCell>Format</Table.HeaderCell>
        <Table.HeaderCell>Time Limit</Table.HeaderCell>
        <Table.HeaderCell>Cutoff</Table.HeaderCell>
        <Table.HeaderCell>Proceed</Table.HeaderCell>
      </Table.Row>
    </Table.Header>
  )
}

function ActivityRow({ activity, venue, round, room }) {
  // note: round may be undefined for custom activities like lunch

  const { name, startTime, endTime } = activity
  const timeZone = venue.timezone

  return (
    <Table.Row>
      <Table.Cell>{getShortTime(startTime, timeZone)}</Table.Cell>
      <Table.Cell>{getShortTime(endTime, timeZone)}</Table.Cell>

      <Table.Cell>{name}</Table.Cell>

      <Table.Cell>{room.name}</Table.Cell>

      <Table.Cell>{round?.format && getFormatName(round.format)}</Table.Cell>
      <TableCell>
        {round?.timeLimit && `${round.timeLimit.centiseconds / 100} seconds`}
      </TableCell>
      <TableCell>
        {round?.cutoff && `${round.cutoff.attemptResult / 100} seconds`}
      </TableCell>
      <TableCell>
        {round?.advancementCondition &&
          `Top ${round.advancementCondition.level} ${round.advancementCondition.type} proceed`}
      </TableCell>
    </Table.Row>
  )
}

const compareActivities = (a, b) => {
  // sort by start time, with longer activities first for ties
  if (a.startTime < b.startTime) {
    return -1
  }
  if (a.startTime > b.startTime) {
    return 1
  }
  if (a.endTime < b.endTime) {
    return 1
  }
  if (a.endTime > b.endTime) {
    return -1
  }
  return 0
}

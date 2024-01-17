import { useQuery } from '@tanstack/react-query'
import { CubingIcon, FlagIcon } from '@thewca/wca-components'
import React, { useContext, useEffect, useMemo, useReducer, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { Dimmer, DimmerDimmable, Icon, Loader, Table } from 'semantic-ui-react'
import { CompetitionContext } from '../../../api/helper/context/competition_context'
import { getConfirmedRegistrations, getPsychSheetForEvent } from '../../../api/registration/get/get_registrations'
import { useUserData } from '../../../hooks/useUserData'
import { addUserData } from '../../../lib/users'
import { setMessage } from '../../../ui/events/messages'
import LoadingMessage from '../../../ui/messages/loadingMessage'

function sortReducer(state, action) {
  if (action.type === 'CHANGE_SORT') {
    if (state.sortColumn === action.sortColumn) {
      return {
        ...state,
        sortDirection:
          state.sortDirection === 'ascending' ? 'descending' : 'ascending',
      }
    }
    switch (action.sortColumn) {
      case 'name':
      case 'country':
      case 'total': {
        return {
          sortColumn: action.sortColumn,
          sortDirection: 'ascending',
        }
      }
      default: {
        throw new Error('Unknown Column')
      }
    }
  }
  throw new Error('Unknown Action')
}

export default function RegistrationList() {
  const { competitionInfo } = useContext(CompetitionContext)
  const { t } = useTranslation()

  const { isLoading: isLoadingRegistrations, data: registrations } = useQuery({
    queryKey: ['registrations', competitionInfo.id],
    queryFn: () => getConfirmedRegistrations(competitionInfo.id),
    retry: false,
    onError: (err) => {
      const { errorCode } = err
      setMessage(
        errorCode
          ? t(`errors.${errorCode}`)
          : 'Fetching Registrations failed with error: ' + err.message,
        'negative',
      )
    },
  })

  const { isLoading: infoLoading, data: userInfo } = useUserData(
    (registrations ?? []).map((r) => r.user_id),
  )

  const [state, dispatch] = useReducer(sortReducer, {
    sortColumn: '',
    sortDirection: undefined,
  })

  const { sortColumn, sortDirection } = state

  const [psychSheetEvent, setPsychSheetEvent] = useState();
  const [psychSheetSortBy, setPsychSheetSortBy] = useState('single');

  const registrationsWithUser = useMemo(() => {
    if (registrations && userInfo) {
      return addUserData(registrations, userInfo)
    }
    return []
  }, [registrations, userInfo])

  const { isLoading: isLoadingPsychSheet, data: psychSheetResults } = useQuery({
    queryKey: ['psychSheet', competitionInfo.id, psychSheetEvent, psychSheetSortBy],
    queryFn: () => getPsychSheetForEvent(competitionInfo.id, psychSheetEvent, psychSheetSortBy),
    retry: false,
    enabled: psychSheetEvent !== undefined,
  });

  useEffect(() => {
    if (psychSheetResults !== undefined) {
      setPsychSheetSortBy(psychSheetResults.sort_by);
    }
  }, [psychSheetResults]);

  const data = useMemo(() => {
    if (registrationsWithUser) {
      const sorted = registrations.sort((a, b) => {
        if (sortColumn === 'name') {
          return a.user.name.localeCompare(b.user.name)
        }
        if (sortColumn === 'country') {
          return a.user.country.name.localeCompare(b.user.country.name)
        }
        if (sortColumn === 'total') {
          return a.competing.event_ids.length - b.competing.event_ids.length
        }
        return 0
      })
      if (sortDirection === 'descending') {
        return sorted.toReversed()
      }
      return sorted
    }
    if (psychSheetEvent !== undefined && psychSheetResults) {
      return psychSheetResults.sorted_rankings;
    }
    return []
  }, [registrationsWithUser, sortColumn, sortDirection, psychSheetEvent, psychSheetResults])

  const { newcomers, totalEvents, countrySet, eventCounts } = useMemo(() => {
    if (!data) {
      return {
        newcomers: 0,
        totalEvents: 0,
        countrySet: new Set(),
        eventCounts: new Map(),
      }
    }
    return data.reduce(
      (info, registration) => {
        if (registration.user.wca_id === undefined) {
          info.newcomers++
        }
        info.countrySet.add(registration.user.country.iso2)
        info.totalEvents += registration.competing.event_ids.length
        competitionInfo.event_ids.forEach((id) => {
          if (registration.competing.event_ids.includes(id)) {
            // We can safely ignore the undefined case here because we initialize the map with zeroes
            info.eventCounts.set(id, info.eventCounts.get(id) + 1)
          }
        })
        return info
      },
      {
        newcomers: 0,
        totalEvents: 0,
        countrySet: new Set(),
        // We have to use a Map instead of an object to preserve event order
        eventCounts: competitionInfo.event_ids.reduce((counts, eventId) => {
          counts.set(eventId, 0)
          return counts
        }, new Map()),
      },
    )
  }, [competitionInfo.event_ids, data]);

  const PsychSheetBody = ({ userId }) => {
    if (isLoadingPsychSheet) return null;

    const psychResultForUser = getPsychResult(userId);
    const psychRanking = getPsychRanking(userId);

    return (
      <>
        <Table.Cell>{psychRanking}</Table.Cell>
        <Table.Cell>{psychResultForUser.single_best}</Table.Cell>
        <Table.Cell>{psychResultForUser.average_best}</Table.Cell>
      </>
    );
  }

  return isLoadingRegistrations || infoLoading ? (
    <LoadingMessage />
  ) : (
    <div>
      <Table sortable textAlign="left">
        <Table.Header>
          <Table.Row>
            <Table.HeaderCell
              sorted={sortColumn === 'name' ? sortDirection : undefined}
              onClick={() =>
                dispatch({ type: 'CHANGE_SORT', sortColumn: 'name' })
              }
            >
              Name
            </Table.HeaderCell>
            <Table.HeaderCell
              sorted={sortColumn === 'country' ? sortDirection : undefined}
              onClick={() =>
                dispatch({ type: 'CHANGE_SORT', sortColumn: 'country' })
              }
            >
              Citizen Of
            </Table.HeaderCell>
            {!psychSheetEvent ? (
              <>
                {(
                  competitionInfo.event_ids.map((id) => (
                    <Table.HeaderCell
                      key={`registration-table-header-${id}`}
                      onClick={() =>
                        setPsychSheetEvent(id)
                      }
                    >
                      <CubingIcon event={id} selected />
                    </Table.HeaderCell>
                  ))
                )}
                <Table.HeaderCell
                  sorted={sortColumn === 'total' ? sortDirection : undefined}
                  onClick={() =>
                    dispatch({ type: 'CHANGE_SORT', sortColumn: 'total' })
                  }
                >
                  Total
                </Table.HeaderCell>
              </>
            ) : (
              <>
                <Table.HeaderCell
                  icon
                  onClick={() =>
                    setPsychSheetEvent(undefined)
                  }
                >
                  <CubingIcon event={psychSheetEvent} selected size="2x" />
                  <Icon name="delete" />
                </Table.HeaderCell>
                <Table.HeaderCell icon>
                  <Icon name="trophy" />
                </Table.HeaderCell>
                <Table.HeaderCell
                  sorted={psychSheetSortBy === 'single' ? 'ascending' : undefined}
                  onClick={() =>
                    setPsychSheetSortBy('single')
                  }
                >
                  Single
                </Table.HeaderCell>
                <Table.HeaderCell
                  sorted={psychSheetSortBy === 'average' ? 'ascending' : undefined}
                  onClick={() =>
                    setPsychSheetSortBy('average')
                  }
                >
                  Average
                </Table.HeaderCell>
              </>
            )}
          </Table.Row>
        </Table.Header>
        <Table.Body>
          {data ? (
            data.map((registration) => (
              <Table.Row key={`registration-table-row-${registration.user.id}`}>
                <Table.Cell>
                  {registration.user.wca_id ? (
                    <a
                      href={`https://worldcubeassociation.org/persons/${registration.user.wca_id}`}
                    >
                      {registration.user.name}
                    </a>
                  ) : (
                    registration.user.name
                  )}
                </Table.Cell>
                <Table.Cell>
                  <FlagIcon iso2={registration.user.country.iso2.toLowerCase()} />
                  {registration.user.country.name}
                </Table.Cell>
                {psychSheetEvent === undefined ? (
                  <>
                    {competitionInfo.event_ids.map((id) => (
                      <Table.Cell
                        key={`registration-table-row-${registration.user.id}-${id}`}
                      >
                        {registration.competing.event_ids.includes(id) ? <CubingIcon event={id} selected /> : null}
                      </Table.Cell>
                    ))}
                    <Table.Cell>
                      {registration.competing.event_ids.length}
                    </Table.Cell>
                  </>
                ) : (
                  <DimmerDimmable dimmed={isLoadingPsychSheet}>
                    <Table.Cell>{registration.pos}</Table.Cell>
                    <Table.Cell>{psychSheetSortBy === 'single' ? registration.single_rank : registration.average_rank}</Table.Cell>
                    <Table.Cell>{registration.single_best}</Table.Cell>
                    <Table.Cell>{registration.average_best}</Table.Cell>

                    <Dimmer active={isLoadingPsychSheet} inverted>
                      <Loader inverted />
                    </Dimmer>
                  </DimmerDimmable>
                )}
              </Table.Row>
            ))
          ) : (
            <Table.Row>
              <Table.Cell width={12}> No matching records found</Table.Cell>
            </Table.Row>
          )}
        </Table.Body>
        <Table.Footer>
          <Table.Row>
            <Table.Cell>{`${newcomers} First-Timers + ${
              registrations.length - newcomers
            } Returners = ${registrations.length} People`}</Table.Cell>
            <Table.Cell>{`${countrySet.size}  Countries`}</Table.Cell>
            {psychSheetEvent === undefined ? (
              <>
                {[...eventCounts.entries()].map(([id, count]) => (
                  <Table.Cell key={`footer-count-${id}`}>{count}</Table.Cell>
                ))}
                <Table.Cell>{totalEvents}</Table.Cell>
              </>
            ) : (
              <>
                <Table.Cell />
                <Table.Cell />
                <Table.Cell />
                <Table.Cell />
              </>
            )}
          </Table.Row>
        </Table.Footer>
      </Table>
    </div>
  )
}

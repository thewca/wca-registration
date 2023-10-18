import { useQuery } from '@tanstack/react-query'
import { CubingIcon, FlagIcon } from '@thewca/wca-components'
import React, { useContext, useEffect, useMemo, useReducer } from 'react'
import { Table } from 'semantic-ui-react'
import { CompetitionContext } from '../../../api/helper/context/competition_context'
import { getConfirmedRegistrations } from '../../../api/registration/get/get_registrations'
import { setMessage } from '../../../ui/events/messages'
import LoadingMessage from '../../../ui/messages/loadingMessage'
import styles from './list.module.scss'

function sortReducer(state, action) {
  if (action.type === 'CHANGE_SORT') {
    if (state.column === action.column) {
      return {
        ...state,
        data: state.data.slice().reverse(),
        direction: state.direction === 'ascending' ? 'descending' : 'ascending',
      }
    }
    switch (action.column) {
      case 'name': {
        return {
          column: action.column,
          data: state.data.sort((a, b) =>
            a.user.name.localeCompare(b.user.name)
          ),
          direction: 'ascending',
        }
      }
      case 'country': {
        return {
          column: action.column,
          data: state.data.sort((a, b) =>
            a.user.country.name.localeCompare(b.user.country.name)
          ),
          direction: 'ascending',
        }
      }
      case 'total': {
        return {
          column: action.column,
          data: state.data.sort(
            (a, b) => a.event_ids.length - b.event_ids.length
          ),
          direction: 'ascending',
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
  const { isLoading, data: registrations } = useQuery({
    queryKey: ['registrations', competitionInfo.id],
    queryFn: () => getConfirmedRegistrations(competitionInfo.id),
    retry: false,
    onError: (err) => {
      setMessage(err.message, 'error')
    },
  })

  const [state, dispatch] = useReducer(sortReducer, {
    column: '',
    data: registrations,
    direction: undefined,
  })
  const { column, data, direction } = state
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
      }
    )
  }, [competitionInfo.event_ids, data])

  return (
    <div className={styles.list}>
      {isLoading ? (
        <LoadingMessage />
      ) : (
        <div className="registrations-table-wrapper">
          <Table className="registrations-table" sortable textAlign="left">
            <Table.Header className="registrations-table-header">
              <Table.Row>
                <Table.HeaderCell
                  className="registrations-table-header-item"
                  sorted={column === 'name' ? direction : undefined}
                  onClick={() =>
                    dispatch({ type: 'CHANGE_SORT', column: 'name' })
                  }
                >
                  Name
                </Table.HeaderCell>
                <Table.HeaderCell
                  className="registrations-table-header-item"
                  sorted={column === 'country' ? direction : undefined}
                  onClick={() =>
                    dispatch({ type: 'CHANGE_SORT', column: 'country' })
                  }
                >
                  Citizen Of
                </Table.HeaderCell>
                {competitionInfo.event_ids.map((id) => (
                  <Table.HeaderCell
                    key={`registration-table-header-${id}`}
                    className="registrations-table-header-item"
                  >
                    <CubingIcon event={id} selected />
                  </Table.HeaderCell>
                ))}
                <Table.HeaderCell
                  className="registrations-table-header-item"
                  sorted={column === 'total' ? direction : undefined}
                  onClick={() =>
                    dispatch({ type: 'CHANGE_SORT', column: 'total' })
                  }
                >
                  Total
                </Table.HeaderCell>
              </Table.Row>
            </Table.Header>
            <Table.Body>
              {data ? (
                data.map((registration) => (
                  <Table.Row
                    key={`registration-table-row-${registration.user.id}`}
                  >
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
                      <FlagIcon iso2={registration.user.country.iso2} />
                      {registration.user.country.name}
                    </Table.Cell>
                    {competitionInfo.event_ids.map((id) => {
                      if (registration.competing.event_ids.includes(id)) {
                        return (
                          <Table.Cell
                            key={`registration-table-row-${registration.user.id}-${id}`}
                          >
                            <CubingIcon event={id} selected={true} />
                          </Table.Cell>
                        )
                      }
                      return (
                        <Table.Cell
                          key={`registration-table-row-${registration.user.id}-${id}`}
                        />
                      )
                    })}
                    <Table.Cell>
                      {registration.competing.event_ids.length}
                    </Table.Cell>
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
                {[...eventCounts.entries()].map(([id, count]) => (
                  <Table.Cell key={`footer-count-${id}`}>{count}</Table.Cell>
                ))}
                <Table.Cell>{totalEvents}</Table.Cell>
              </Table.Row>
            </Table.Footer>
          </Table>
        </div>
      )}
    </div>
  )
}

import { useQuery } from '@tanstack/react-query'
import { FlagIcon, UiIcon } from '@thewca/wca-components'
import React, { useContext, useMemo, useReducer } from 'react'
import { Link } from 'react-router-dom'
import { Checkbox, Popup, Table } from 'semantic-ui-react'
import { CompetitionContext } from '../../../api/helper/context/competition_context'
import { getAllRegistrations } from '../../../api/registration/get/get_registrations'
import LoadingMessage from '../../../ui/messages/loadingMessage'
import styles from './list.module.scss'
import RegistrationActions from './RegistrationActions'

// Currently it is at the developer's discretion to make sure
// an attendee is added to the right list.
// One Solution would be to keep the registrations state as
// the source of truth and partition as needed
const reducer = (state, action) => {
  const { type, attendee } = action
  // Make sure no one adds an attendee twice
  if (
    type.startsWith('add') &&
    [...state.waiting, ...state.accepted, ...state.deleted].includes(attendee)
  ) {
    return state
  }
  switch (type) {
    case 'add-waiting':
      return {
        waiting: [...state.waiting, attendee],
        accepted: state.accepted,
        deleted: state.deleted,
      }
    case 'remove-waiting':
      return {
        waiting: state.waiting.filter(
          (selectedAttendee) => selectedAttendee !== attendee
        ),
        accepted: state.accepted,
        deleted: state.deleted,
      }
    case 'add-accepted':
      return {
        accepted: [...state.accepted, attendee],
        waiting: state.waiting,
        deleted: state.deleted,
      }
    case 'remove-accepted':
      return {
        accepted: state.accepted.filter(
          (selectedAttendee) => selectedAttendee !== attendee
        ),
        waiting: state.waiting,
        deleted: state.deleted,
      }
    case 'add-deleted':
      return {
        deleted: [...state.deleted, attendee],
        accepted: state.accepted,
        waiting: state.deleted,
      }
    case 'remove-deleted':
      return {
        deleted: state.deleted.filter(
          (selectedAttendee) => selectedAttendee !== attendee
        ),
        accepted: state.accepted,
        waiting: state.deleted,
      }
    case 'clear-selected': {
      return {
        waiting: [],
        accepted: [],
        deleted: [],
      }
    }
    default:
      throw new Error('Unknown action.')
  }
}

const partitionRegistrations = (registrations) => {
  return registrations.reduce(
    (result, registration) => {
      switch (registration.registration_status) {
        case 'waiting':
          result.waiting.push(registration)
          break
        case 'accepted':
          result.accepted.push(registration)
          break
        case 'deleted':
          result.deleted.push(registration)
          break
        default:
          break
      }
      return result
    },
    { waiting: [], accepted: [], deleted: [] }
  )
}

// Semantic Table only allows truncating _all_ columns in a table in
// single line fixed mode. As we only want to truncate the comment/admin notes
// this function is used to manually truncate the columns.
// TODO: We could fix this by building our own table component here
const truncateComment = (comment) =>
  comment?.length > 12 ? comment.slice(0, 12) + '...' : comment

export default function RegistrationAdministrationList() {
  const { competitionInfo } = useContext(CompetitionContext)
  const {
    isLoading,
    data: registrations,
    refetch,
  } = useQuery({
    queryKey: ['registrations-admin', competitionInfo.id],
    queryFn: () => getAllRegistrations(competitionInfo.id),
    refetchOnWindowFocus: false,
    refetchOnReconnect: false,
    staleTime: Infinity,
    refetchOnMount: 'always',
  })
  const [selected, dispatch] = useReducer(reducer, {
    waiting: [],
    accepted: [],
    deleted: [],
  })

  const { waiting, accepted, deleted } = useMemo(
    () => partitionRegistrations(registrations ?? []),
    [registrations]
  )

  return isLoading ? (
    <div className={styles.listContainer}>
      <LoadingMessage />
    </div>
  ) : (
    <>
      <div className={styles.listContainer}>
        <div className={styles.listHeader}> Incoming registrations </div>
        <RegistrationAdministrationTable
          registrations={waiting}
          add={(attendee) => dispatch({ type: 'add-waiting', attendee })}
          remove={(attendee) => dispatch({ type: 'remove-waiting', attendee })}
          competition_id={competitionInfo.id}
          selected={selected.waiting}
        />
        <div className={styles.listHeader}> Approved registrations </div>
        <RegistrationAdministrationTable
          registrations={accepted}
          add={(attendee) => dispatch({ type: 'add-accepted', attendee })}
          remove={(attendee) => dispatch({ type: 'remove-accepted', attendee })}
          competition_id={competitionInfo.id}
          selected={selected.accepted}
        />
        <div className={styles.listHeader}> Deleted registrations </div>
        <RegistrationAdministrationTable
          registrations={deleted}
          add={(attendee) => dispatch({ type: 'add-deleted', attendee })}
          remove={(attendee) => dispatch({ type: 'remove-deleted', attendee })}
          competition_id={competitionInfo.id}
          selected={selected.deleted}
        />
      </div>
      <RegistrationActions
        selected={selected}
        refresh={async () => {
          await refetch()
          dispatch({ type: 'clear-selected' })
        }}
      />
    </>
  )
}

function RegistrationAdministrationTable({
  registrations,
  add,
  remove,
  competition_id,
  selected,
}) {
  return (
    <Table textAlign="left" className={styles.list} singleLine>
      <Table.Header>
        <Table.Row>
          <Table.HeaderCell>
            <Checkbox
              onChange={(_, data) => {
                registrations.forEach((registration) =>
                  data.checked
                    ? add(registration.user.id)
                    : remove(registration.user.id)
                )
              }}
            />
          </Table.HeaderCell>
          <Table.HeaderCell />
          <Table.HeaderCell>WCA ID</Table.HeaderCell>
          <Table.HeaderCell>Name</Table.HeaderCell>
          <Table.HeaderCell>Citizen of</Table.HeaderCell>
          <Table.HeaderCell>Registered on</Table.HeaderCell>
          <Table.HeaderCell>Number of Events</Table.HeaderCell>
          <Table.HeaderCell>Guests</Table.HeaderCell>
          <Table.HeaderCell>Comment</Table.HeaderCell>
          <Table.HeaderCell>Administrative notes</Table.HeaderCell>
          <Table.HeaderCell>Email</Table.HeaderCell>
        </Table.Row>
      </Table.Header>
      <Table.Body>
        {registrations.length > 0 ? (
          registrations.map((registration) => {
            return (
              <Table.Row
                key={registration.user.id}
                active={selected.includes(registration.user.id)}
              >
                <Table.Cell>
                  <Checkbox
                    onChange={(_, data) => {
                      if (data.checked) {
                        add(registration.user.id)
                      } else {
                        remove(registration.user.id)
                      }
                    }}
                    checked={selected.includes(registration.user.id)}
                  />
                </Table.Cell>
                <Table.Cell>
                  <Link to={`/${competition_id}/${registration.user.id}/edit`}>
                    Edit
                  </Link>
                </Table.Cell>
                <Table.Cell>
                  {registration.user.wca_id ? (
                    <a
                      href={`https://www.worldcubeassociation.org/persons/${registration.user.wca_id}`}
                    >
                      {registration.user.wca_id}
                    </a>
                  ) : (
                    ''
                  )}
                </Table.Cell>
                <Table.Cell>{registration.user.name}</Table.Cell>
                <Table.Cell>
                  <FlagIcon iso2={registration.user.country.iso2} />
                  {registration.user.country.name}
                </Table.Cell>
                <Table.Cell>
                  <Popup
                    content={new Date(
                      registration.registered_on
                    ).toTimeString()}
                    trigger={
                      <span>
                        {new Date(
                          registration.registered_on
                        ).toLocaleDateString()}
                      </span>
                    }
                  />
                </Table.Cell>
                <Table.Cell>{registration.event_ids.length}</Table.Cell>
                <Table.Cell>{registration.guests}</Table.Cell>
                <Table.Cell title={registration.comment}>
                  {truncateComment(registration.comment)}
                </Table.Cell>
                <Table.Cell title={registration.admin_comment}>
                  {truncateComment(registration.admin_comment)}
                </Table.Cell>
                <Table.Cell>
                  <a
                    href={`mailto:${registration.user_id}@worldcubeassociation.org`}
                  >
                    <UiIcon name="mail" />
                  </a>
                </Table.Cell>
              </Table.Row>
            )
          })
        ) : (
          <Table.Row>
            <Table.Cell colSpan={6}>No matching records found</Table.Cell>
          </Table.Row>
        )}
      </Table.Body>
    </Table>
  )
}

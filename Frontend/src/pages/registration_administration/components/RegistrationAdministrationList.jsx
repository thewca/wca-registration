import { useQuery } from '@tanstack/react-query'
import { CubingIcon, FlagIcon, UiIcon } from '@thewca/wca-components'
import React, { useContext, useMemo, useReducer } from 'react'
import { Link } from 'react-router-dom'
import { Checkbox, Form, Header, Icon, Popup, Table } from 'semantic-ui-react'
import { CompetitionContext } from '../../../api/helper/context/competition_context'
import { PermissionsContext } from '../../../api/helper/context/permission_context'
import { getAllRegistrations } from '../../../api/registration/get/get_registrations'
import { BASE_ROUTE } from '../../../routes'
import { setMessage } from '../../../ui/events/messages'
import LoadingMessage from '../../../ui/messages/loadingMessage'
import styles from './list.module.scss'
import RegistrationActions from './RegistrationActions'
import getCompetitorInfo from '../../../api/competition/get/get_competitor_info'

const selectedReducer = (state, action) => {
  let newState = [...state]

  const { type, attendee, attendees } = action
  const idList = attendees || [attendee]

  switch (type) {
    case 'add':
      idList.forEach((id) => {
        // Make sure no one adds an attendee twice
        if (!newState.includes(id)) newState.push(id)
      })
      break

    case 'remove':
      newState = newState.filter((id) => !idList.includes(id))
      break

    case 'clear-selected':
      return []

    default:
      throw new Error('Unknown action.')
  }

  return newState
}

const partitionRegistrations = (registrations) => {
  return registrations.reduce(
    (result, registration) => {
      switch (registration.competing.registration_status) {
        case 'pending':
          result.pending.push(registration)
          break
        case 'waiting_list':
          result.waiting.push(registration)
          break
        case 'accepted':
          result.accepted.push(registration)
          break
        case 'cancelled':
          result.cancelled.push(registration)
          break
        default:
          break
      }
      return result
    },
    { pending: [], waiting: [], accepted: [], cancelled: [] }
  )
}

const expandableColumns = {
  dob: 'Date of Birth',
  region: 'Region',
  events: 'Events',
  comments: 'Comment & Note',
  email: 'Email',
}
const initialExpandedColumns = {
  dob: false,
  region: false,
  events: false,
  comments: true,
  email: false,
}

const columnReducer = (state, action) => {
  if (action.type === 'reset') {
    return initialExpandedColumns
  }
  if (Object.keys(expandableColumns).includes(action.column)) {
    return { ...state, [action.column]: !state[action.column] }
  }
  return state
}

// Semantic Table only allows truncating _all_ columns in a table in
// single line fixed mode. As we only want to truncate the comment/admin notes
// this function is used to manually truncate the columns.
// TODO: We could fix this by building our own table component here
const truncateComment = (comment) =>
  comment?.length > 12 ? comment.slice(0, 12) + '...' : comment

export default function RegistrationAdministrationList() {
  const { competitionInfo } = useContext(CompetitionContext)

  const [expandedColumns, dispatchColumns] = useReducer(
    columnReducer,
    initialExpandedColumns
  )

  const {
    isLoading: isRegistrationsLoading,
    data: registrations,
    refetch,
  } = useQuery({
    queryKey: ['registrations-admin', competitionInfo.id],
    queryFn: () => getAllRegistrations(competitionInfo.id),
    refetchOnWindowFocus: false,
    refetchOnReconnect: false,
    staleTime: Infinity,
    refetchOnMount: 'always',
    retry: false,
    onError: (err) => {
      setMessage(err.message, 'error')
    },
  })

  const { isLoading: isPiiLoading, data: piiData } = useQuery({
    queryKey: ['registrations-pii', competitionInfo.id],
    queryFn: () => getCompetitorInfo(competitionInfo.id),
    refetchOnWindowFocus: false,
    refetchOnReconnect: false,
    staleTime: Infinity,
    refetchOnMount: 'always',
    retry: false,
    onError: (err) => {
      setMessage(err.message, 'error')
    },
  })

  const registrationsWithPii = useMemo(
    () => addPii(registrations ?? [], piiData ?? []),
    [registrations, piiData]
  )

  const { waiting, accepted, cancelled, pending } = useMemo(
    () => partitionRegistrations(registrationsWithPii ?? []),
    [registrationsWithPii]
  )

  const [selected, dispatch] = useReducer(selectedReducer, [])
  const partitionedSelected = useMemo(
    () => ({
      pending: selected.filter((id) =>
        pending.some((reg) => id === reg.user.id)
      ),
      waiting: selected.filter((id) =>
        waiting.some((reg) => id === reg.user.id)
      ),
      accepted: selected.filter((id) =>
        accepted.some((reg) => id === reg.user.id)
      ),
      cancelled: selected.filter((id) =>
        cancelled.some((reg) => id === reg.user.id)
      ),
    }),
    [selected, pending, waiting, accepted, cancelled]
  )

  const select = (attendees) => dispatch({ type: 'add', attendees })
  const unselect = (attendees) => dispatch({ type: 'remove', attendees })

  // some sticky/floating bar somewhere with totals/info would be better
  // than putting this in the table headers which scroll out of sight
  const spotsRemaining =
    (competitionInfo.competitor_limit ?? Infinity) - accepted.length
  const spotsRemainingText = `; ${spotsRemaining} spot(s) remaining`

  return isRegistrationsLoading || isPiiLoading ? (
    <LoadingMessage />
  ) : (
    <>
      <Form>
        <Form.Group widths="equal">
          {Object.entries(expandableColumns).map(([id, name]) => (
            <Form.Field key={id}>
              <Checkbox
                name={id}
                label={name}
                toggle
                checked={expandedColumns[id]}
                onChange={() => dispatchColumns({ column: id })}
              />
            </Form.Field>
          ))}
        </Form.Group>
      </Form>

      <div className={styles.listContainer}>
        <Header>Pending registrations ({pending.length})</Header>
        <RegistrationAdministrationTable
          columnsExpanded={expandedColumns}
          registrations={pending}
          selected={partitionedSelected.pending}
          select={select}
          unselect={unselect}
          competition_id={competitionInfo.id}
        />

        <Header>
          Approved registrations ({accepted.length}
          {competitionInfo.competitor_limit && (
            <>
              {`/${competitionInfo.competitor_limit}`}
              {spotsRemainingText}
            </>
          )}
          )
        </Header>
        <RegistrationAdministrationTable
          columnsExpanded={expandedColumns}
          registrations={accepted}
          selected={partitionedSelected.accepted}
          select={select}
          unselect={unselect}
          competition_id={competitionInfo.id}
        />

        <Header>
          Waitlisted registrations ({waiting.length}
          {competitionInfo.competitor_limit && spotsRemainingText})
        </Header>
        <RegistrationAdministrationTable
          columnsExpanded={expandedColumns}
          registrations={waiting}
          selected={partitionedSelected.waiting}
          select={select}
          unselect={unselect}
          competition_id={competitionInfo.id}
        />

        <Header>Cancelled registrations ({cancelled.length})</Header>
        <RegistrationAdministrationTable
          columnsExpanded={expandedColumns}
          registrations={cancelled}
          selected={partitionedSelected.cancelled}
          select={select}
          unselect={unselect}
          competition_id={competitionInfo.id}
        />
      </div>

      <RegistrationActions
        partitionedSelected={partitionedSelected}
        refresh={async () => {
          await refetch()
          dispatch({ type: 'clear-selected' })
        }}
        registrations={registrations}
        spotsRemaining={spotsRemaining}
      />
    </>
  )
}

function RegistrationAdministrationTable({
  columnsExpanded,
  registrations,
  selected,
  select,
  unselect,
}) {
  const handleHeaderCheck = (_, data) => {
    if (data.checked) {
      select(registrations.map(({ user }) => user.id))
    } else {
      unselect(registrations.map(({ user }) => user.id))
    }
  }

  return (
    <Table striped textAlign="left">
      <TableHeader
        columnsExpanded={columnsExpanded}
        showCheckbox={registrations.length > 0}
        isChecked={registrations.length === selected.length}
        onCheckboxChanged={handleHeaderCheck}
      />

      <Table.Body>
        {registrations.length > 0 ? (
          registrations.map((registration) => {
            const id = registration.user.id
            return (
              <TableRow
                key={id}
                columnsExpanded={columnsExpanded}
                registration={registration}
                isSelected={selected.includes(id)}
                onCheckboxChange={(_, data) => {
                  if (data.checked) {
                    select([id])
                  } else {
                    unselect([id])
                  }
                }}
              />
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

function TableHeader({
  columnsExpanded,
  showCheckbox,
  isChecked,
  onCheckboxChanged,
}) {
  const { competitionInfo } = useContext(CompetitionContext)
  const { isOrganizerOrDelegate } = useContext(PermissionsContext)

  const { dob, events, comments } = columnsExpanded

  return (
    <Table.Header>
      <Table.Row>
        <Table.HeaderCell>
          {showCheckbox && (
            <Checkbox checked={isChecked} onChange={onCheckboxChanged} />
          )}
        </Table.HeaderCell>
        {isOrganizerOrDelegate && <Table.HeaderCell />}
        <Table.HeaderCell>WCA ID</Table.HeaderCell>
        <Table.HeaderCell>Name</Table.HeaderCell>
        {dob && <Table.HeaderCell>DOB</Table.HeaderCell>}
        <Table.HeaderCell>Region</Table.HeaderCell>
        <Table.HeaderCell>Registered on</Table.HeaderCell>
        {competitionInfo['using_stripe_payments?'] && (
          <>
            <Table.HeaderCell>Payment Status</Table.HeaderCell>
            <Table.HeaderCell>Paid on</Table.HeaderCell>
          </>
        )}
        {events ? (
          competitionInfo.event_ids.map((eventId) => (
            <Table.HeaderCell key={`event-${eventId}`}>
              <CubingIcon event={eventId} size="1x" selected />
            </Table.HeaderCell>
          ))
        ) : (
          <Table.HeaderCell>Events</Table.HeaderCell>
        )}
        <Table.HeaderCell>Guests</Table.HeaderCell>
        {comments && (
          <>
            <Table.HeaderCell>Comment</Table.HeaderCell>
            <Table.HeaderCell>Admin Note</Table.HeaderCell>
          </>
        )}
        <Table.HeaderCell>Email</Table.HeaderCell>
      </Table.Row>
    </Table.Header>
  )
}

function TableRow({
  columnsExpanded,
  registration,
  isSelected,
  onCheckboxChange,
}) {
  const { competitionInfo } = useContext(CompetitionContext)
  const { isOrganizerOrDelegate } = useContext(PermissionsContext)

  const { dob, region, events, comments, email } = columnsExpanded
  const {
    id,
    wca_id,
    name,
    country,
    dob: dateOfBirth,
    email: emailAddress,
  } = registration.user
  const { registered_on, event_ids, comment, admin_comment } =
    registration.competing
  const { payment_status, updated_at } = registration.payment

  const copyEmail = () => {
    navigator.clipboard.writeText(emailAddress)
    setMessage('Copied email address to clipboard.', 'positive')
  }

  return (
    <Table.Row key={id} active={isSelected}>
      <Table.Cell>
        <Checkbox onChange={onCheckboxChange} checked={isSelected} />
      </Table.Cell>

      {isOrganizerOrDelegate && (
        <Table.Cell>
          <Link to={`${BASE_ROUTE}/${competitionInfo.id}/${id}/edit`}>
            Edit
          </Link>
        </Table.Cell>
      )}

      <Table.Cell>
        {wca_id && (
          <a href={`https://www.worldcubeassociation.org/persons/${wca_id}`}>
            {wca_id}
          </a>
        )}
      </Table.Cell>

      <Table.Cell>{name}</Table.Cell>

      {dob && <Table.Cell>{dateOfBirth}</Table.Cell>}

      <Table.Cell>
        {region ? (
          <>
            <FlagIcon iso2={country.iso2} /> {region && country.name}
          </>
        ) : (
          <Popup
            content={country.name}
            trigger={
              <span>
                <FlagIcon iso2={country.iso2} />
              </span>
            }
          />
        )}
      </Table.Cell>

      <Table.Cell>
        <Popup
          content={new Date(registered_on).toTimeString()}
          trigger={<span>{new Date(registered_on).toLocaleDateString()}</span>}
        />
      </Table.Cell>

      {competitionInfo['using_stripe_payments?'] && (
        <>
          <Table.Cell>{payment_status ?? 'not paid'}</Table.Cell>
          <Table.Cell>
            {updated_at && (
              <Popup
                content={new Date(updated_at).toTimeString()}
                trigger={
                  <span>{new Date(updated_at).toLocaleDateString()}</span>
                }
              />
            )}
          </Table.Cell>
        </>
      )}

      {events ? (
        competitionInfo.event_ids.map((eventId) => (
          <Table.Cell key={`event-${eventId}`}>
            {event_ids.includes(eventId) && (
              <CubingIcon event={eventId} size="1x" selected />
            )}
          </Table.Cell>
        ))
      ) : (
        <Table.Cell>
          <Popup
            content={event_ids.map((eventId) => (
              <CubingIcon key={eventId} event={eventId} size="3x" selected />
            ))}
            trigger={<span>{event_ids.length}</span>}
          />
        </Table.Cell>
      )}

      <Table.Cell>{registration.guests}</Table.Cell>

      {comments && (
        <>
          <Table.Cell>
            <Popup
              content={comment}
              trigger={<span>{truncateComment(comment)}</span>}
            />
          </Table.Cell>

          <Table.Cell>
            <Popup
              content={admin_comment}
              trigger={<span>{truncateComment(admin_comment)}</span>}
            />
          </Table.Cell>
        </>
      )}

      <Table.Cell>
        <a href={`mailto:${emailAddress}`}>
          {email ? (
            emailAddress
          ) : (
            <Popup
              content={emailAddress}
              trigger={
                <span>
                  <UiIcon name="mail" />
                </span>
              }
            />
          )}
        </a>{' '}
        <Icon link onClick={copyEmail} name="copy" title="Copy Email Address" />
      </Table.Cell>
    </Table.Row>
  )
}

function addPii(registrations, piiData) {
  return registrations.map((registration) => {
    const { email, dob } =
      piiData.find((data) => data.id === registration.user.id) || {}
    return { ...registration, user: { ...registration.user, email, dob } }
  })
}

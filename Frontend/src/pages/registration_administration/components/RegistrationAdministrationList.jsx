import { useQuery } from '@tanstack/react-query'
import { FlagIcon, UiIcon } from '@thewca/wca-components'
import React, { useContext, useMemo, useReducer } from 'react'
import { Link } from 'react-router-dom'
import { Checkbox, Header, Popup, Table } from 'semantic-ui-react'
import { CompetitionContext } from '../../../api/helper/context/competition_context'
import { getAllRegistrations } from '../../../api/registration/get/get_registrations'
import { BASE_ROUTE } from '../../../routes'
import { setMessage } from '../../../ui/events/messages'
import LoadingMessage from '../../../ui/messages/loadingMessage'
import styles from './list.module.scss'
import RegistrationActions from './RegistrationActions'

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
    retry: false,
    onError: (err) => {
      setMessage(err.message, 'error')
    },
  })

  const { waiting, accepted, cancelled, pending } = useMemo(
    () => partitionRegistrations(registrations ?? []),
    [registrations]
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

  function select(attendees) {
    dispatch({ type: 'add', attendees })
  }
  function unselect(attendees) {
    dispatch({ type: 'remove', attendees })
  }

  // some sticky/floating bar somewhere with totals/info would be better
  // than putting this in the table headers which scroll out of sight
  const spotsRemaining = `; ${
    competitionInfo?.competitor_limit - accepted?.length
  } spot(s) remaining`

  return isLoading ? (
    <LoadingMessage />
  ) : (
    <>
      <div className={styles.listContainer}>
        <Header> Pending registrations ({pending.length}) </Header>
        <RegistrationAdministrationTable
          registrations={pending}
          select={select}
          unselect={unselect}
          competition_id={competitionInfo.id}
          selected={partitionedSelected.pending}
        />

        <Header>
          Approved registrations ({accepted.length}
          {competitionInfo.competitor_limit && (
            <>
              {`/${competitionInfo.competitor_limit}`}
              {spotsRemaining}
            </>
          )}
          )
        </Header>
        <RegistrationAdministrationTable
          registrations={accepted}
          select={select}
          unselect={unselect}
          competition_id={competitionInfo.id}
          selected={partitionedSelected.accepted}
        />

        <Header>
          Waitlisted registrations ({waiting.length}
          {competitionInfo.competitor_limit && spotsRemaining})
        </Header>
        <RegistrationAdministrationTable
          registrations={waiting}
          select={select}
          unselect={unselect}
          competition_id={competitionInfo.id}
          selected={partitionedSelected.waiting}
        />

        <Header>Cancelled registrations ({cancelled.length})</Header>
        <RegistrationAdministrationTable
          registrations={cancelled}
          select={select}
          unselect={unselect}
          competition_id={competitionInfo.id}
          selected={partitionedSelected.cancelled}
        />
      </div>

      <RegistrationActions
        partitionedSelected={partitionedSelected}
        refresh={async () => {
          await refetch()
          dispatch({ type: 'clear-selected' })
        }}
        registrations={registrations}
      />
    </>
  )
}

function RegistrationAdministrationTable({
  registrations,
  select,
  unselect,
  competition_id,
  selected,
}) {
  const { competitionInfo } = useContext(CompetitionContext)

  return (
    <Table striped textAlign="left">
      <Table.Header>
        <Table.Row>
          <Table.HeaderCell>
            {registrations.length > 0 && (
              <Checkbox
                checked={registrations.length === selected.length}
                onChange={(_, data) => {
                  data.checked
                    ? select(registrations.map(({ user }) => user.id))
                    : unselect(registrations.map(({ user }) => user.id))
                }}
              />
            )}
          </Table.HeaderCell>
          <Table.HeaderCell />
          <Table.HeaderCell>WCA ID</Table.HeaderCell>
          <Table.HeaderCell>Name</Table.HeaderCell>
          <Table.HeaderCell>Citizen of</Table.HeaderCell>
          <Table.HeaderCell>Registered on</Table.HeaderCell>
          {competitionInfo['using_stripe_payments?'] && (
            <>
              <Table.HeaderCell>Payment status</Table.HeaderCell>
              <Table.HeaderCell>Paid on</Table.HeaderCell>
            </>
          )}
          <Table.HeaderCell># Events</Table.HeaderCell>
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
                      data.checked
                        ? select([registration.user.id])
                        : unselect([registration.user.id])
                    }}
                    checked={selected.includes(registration.user.id)}
                  />
                </Table.Cell>
                <Table.Cell>
                  <Link
                    to={`${BASE_ROUTE}/${competition_id}/${registration.user.id}/edit`}
                  >
                    Edit
                  </Link>
                </Table.Cell>
                <Table.Cell>
                  {registration.user.wca_id && (
                    <a
                      href={`https://www.worldcubeassociation.org/persons/${registration.user.wca_id}`}
                    >
                      {registration.user.wca_id}
                    </a>
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
                      registration.competing.registered_on
                    ).toTimeString()}
                    trigger={
                      <span>
                        {new Date(
                          registration.competing.registered_on
                        ).toLocaleDateString()}
                      </span>
                    }
                  />
                </Table.Cell>

                {competitionInfo['using_stripe_payments?'] && (
                  <>
                    <Table.Cell>
                      {registration.payment.payment_status ?? 'not paid'}
                    </Table.Cell>
                    <Table.Cell>
                      {registration.payment.updated_at && (
                        <Popup
                          content={new Date(
                            registration.payment.updated_at
                          ).toTimeString()}
                          trigger={
                            <span>
                              {new Date(
                                registration.payment.updated_at
                              ).toLocaleDateString()}
                            </span>
                          }
                        />
                      )}
                    </Table.Cell>
                  </>
                )}
                <Table.Cell>
                  {registration.competing.event_ids.length}
                </Table.Cell>
                <Table.Cell>{registration.guests}</Table.Cell>
                <Table.Cell title={registration.competing.comment}>
                  {truncateComment(registration.competing.comment)}
                </Table.Cell>
                <Table.Cell title={registration.competing.admin_comment}>
                  {truncateComment(registration.competing.admin_comment)}
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

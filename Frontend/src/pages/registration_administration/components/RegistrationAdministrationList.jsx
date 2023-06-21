import { FlagIcon } from '@thewca/wca-components'
import React, { useEffect, useMemo, useReducer, useState } from 'react'
import { Link, useParams } from 'react-router-dom'
import { Checkbox, Popup, Table } from 'semantic-ui-react'
import { getAllRegistrations } from '../../../api/registration/get/get_registrations'
import getCompetitorInfo from '../../../api/user/get/get_user_info'
import LoadingMessage from '../../../ui/loadingMessage'
import styles from './list.module.scss'
import RegistrationActions from './RegistrationActions'

const reducer = (state, action) => {
  const { type, attendee } = action
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

export default function RegistrationAdministrationList() {
  const { competition_id } = useParams()
  const [registrations, setRegistrations] = useState([])
  const [isLoading, setIsLoading] = useState(true)
  const [selected, dispatch] = useReducer(reducer, {
    waiting: [],
    accepted: [],
    deleted: [],
  })
  const fetchData = async (competition_id) => {
    const registrations = await getAllRegistrations(competition_id)
    const regList = []
    for (const registration of registrations) {
      registration.user = (
        await getCompetitorInfo(registration.competitor_id)
      ).user
      regList.push(registration)
    }
    return regList
  }
  useEffect(() => {
    fetchData(competition_id).then((registrations) => {
      setRegistrations(registrations)
      setIsLoading(false)
    })
  }, [competition_id])

  const { waiting, accepted, deleted } = useMemo(
    () => partitionRegistrations(registrations),
    [registrations]
  )

  return isLoading ? (
    <div className={styles.list}>
      <LoadingMessage />
    </div>
  ) : (
    <>
      <div className={styles.list}>
        <h2> Incoming registrations </h2>
        <RegistrationAdministrationTable
          registrations={waiting}
          add={(attendee) => dispatch({ type: 'add-waiting', attendee })}
          remove={(attendee) => dispatch({ type: 'remove-waiting', attendee })}
          competition_id={competition_id}
        />
        <h2> Approved registrations </h2>
        <RegistrationAdministrationTable
          registrations={accepted}
          add={(attendee) => dispatch({ type: 'add-accepted', attendee })}
          remove={(attendee) => dispatch({ type: 'remove-accepted', attendee })}
          competition_id={competition_id}
        />
        <h2> Deleted registrations </h2>
        <RegistrationAdministrationTable
          registrations={deleted}
          add={(attendee) => dispatch({ type: 'add-deleted', attendee })}
          remove={(attendee) => dispatch({ type: 'remove-deleted', attendee })}
          competition_id={competition_id}
        />
      </div>
      <RegistrationActions
        selected={selected}
        refresh={() =>
          fetchData(competition_id).then((registrations) => {
            setRegistrations(registrations)
            dispatch({ type: 'clear-selected' })
          })
        }
      />
    </>
  )
}

function RegistrationAdministrationTable({
  registrations,
  add,
  remove,
  competition_id,
}) {
  const [checkedBoxes, setCheckedBoxes] = useState([])
  return (
    <Table textAlign="left">
      <Table.Header>
        <Table.Row>
          <Table.HeaderCell>
            <Checkbox
              onChange={(_, data) => {
                if (data.checked) {
                  setCheckedBoxes(
                    registrations.map((registration) => {
                      add(registration.user.id)
                      return registration.user.id
                    })
                  )
                } else {
                  registrations.forEach((registration) =>
                    remove(registration.user.id)
                  )
                  setCheckedBoxes([])
                }
              }}
            />
          </Table.HeaderCell>
          <Table.HeaderCell />
          <Table.HeaderCell>WCA ID</Table.HeaderCell>
          <Table.HeaderCell>Name</Table.HeaderCell>
          <Table.HeaderCell>Citizen of</Table.HeaderCell>
          <Table.HeaderCell>Registered on</Table.HeaderCell>
          <Table.HeaderCell>Number of Events</Table.HeaderCell>
          <Table.HeaderCell>Comment</Table.HeaderCell>
        </Table.Row>
      </Table.Header>
      <Table.Body>
        {registrations.length > 0 ? (
          registrations.map((registration) => {
            return (
              <Table.Row
                key={registration.user.id}
                active={checkedBoxes.includes(registration.user.id)}
              >
                <Table.Cell>
                  <Checkbox
                    onChange={(_, data) => {
                      if (data.checked) {
                        add(registration.user.id)
                        setCheckedBoxes([...checkedBoxes, registration.user.id])
                      } else {
                        remove(registration.user.id)
                        setCheckedBoxes(
                          checkedBoxes.filter(
                            (box) => registration.user.id !== box
                          )
                        )
                      }
                    }}
                    checked={checkedBoxes.includes(registration.user.id)}
                  />
                </Table.Cell>
                <Table.Cell>
                  <Link to={`/${competition_id}/${registration.user.id}/edit`}>
                    Edit
                  </Link>
                </Table.Cell>
                <Table.Cell>
                  {registration.competitor_id ? (
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
                <Table.Cell>{registration.comment}</Table.Cell>
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

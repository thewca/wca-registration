import { useQuery } from '@tanstack/react-query'
import { RegistrationsTable } from '@thewca/wca-components'
import React, { useContext } from 'react'
import { CompetitionContext } from '../../../api/helper/context/competition_context'
import { getConfirmedRegistrations } from '../../../api/registration/get/get_registrations'
import LoadingMessage from '../../../ui/messages/loadingMessage'
import styles from './list.module.scss'

export default function RegistrationList() {
  // Fetch data
  const { competitionInfo } = useContext(CompetitionContext)

  const { isLoading, data: registrations } = useQuery({
    queryKey: ['registrations', competitionInfo.id],
    queryFn: () => getConfirmedRegistrations(competitionInfo.id),
  })

  return (
    <div className={styles.list}>
      {isLoading ? (
        <LoadingMessage />
      ) : (
        <RegistrationsTable
          registrations={registrations}
          heldEvents={competitionInfo.event_ids}
        />
      )}
    </div>
  )
}

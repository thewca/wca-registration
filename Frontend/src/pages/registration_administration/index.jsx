import React, { useContext } from 'react'
import {
  CAN_ADMINISTER_COMPETITIONS,
  canAdminCompetition,
} from '../../api/auth/get_permissions'
import { CompetitionContext } from '../../api/helper/context/competition_context'
import PermissionMessage from '../../ui/messages/permissionMessage'
import RegistrationAdministrationList from './components/RegistrationAdministrationList'
import styles from './index.module.scss'

export default function RegistrationAdministration() {
  const { competitionInfo } = useContext(CompetitionContext)
  return (
    <div className={styles.container}>
      {canAdminCompetition(competitionInfo.id) ? (
        <RegistrationAdministrationList />
      ) : (
        <PermissionMessage permissionLevel={CAN_ADMINISTER_COMPETITIONS} />
      )}
    </div>
  )
}

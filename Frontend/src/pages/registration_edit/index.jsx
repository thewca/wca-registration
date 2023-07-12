import React, { useContext } from 'react'
import {
  CAN_ADMINISTER_COMPETITIONS,
  canAdminCompetition,
} from '../../api/auth/get_permissions'
import { CompetitionContext } from '../../api/helper/context/competition_context'
import PermissionMessage from '../../ui/messages/permissionMessage'
import RegistrationEditor from './components/RegistrationEditor'
import styles from './index.module.scss'

export default async function RegistrationEdit() {
  const { competitionInfo } = useContext(CompetitionContext)
  return (
    <div className={styles.container}>
      {(await canAdminCompetition(competitionInfo.id)) ? (
        <RegistrationEditor />
      ) : (
        <PermissionMessage permissionLevel={CAN_ADMINISTER_COMPETITIONS} />
      )}
    </div>
  )
}

import { marked } from 'marked'
import React, { useContext } from 'react'
import { useParams } from 'react-router-dom'
import { CompetitionContext } from '../api/helper/context/competition_context'
import styles from './customtab.module.scss'

export default function CustomTab() {
  const { tab_id } = useParams()
  const { competitionInfo } = useContext(CompetitionContext)
  const tab = competitionInfo.tabs.find((tab) => tab.id.toString() === tab_id)
  return (
    <span
      className={styles.customTabContent}
      dangerouslySetInnerHTML={{ __html: marked(tab.content) }}
    />
  )
}

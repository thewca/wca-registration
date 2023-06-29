import React, { useContext } from 'react'
import { CompetitionContext } from '../../api/helper/context/competition_context'

export default function HomePage() {
  const { competitionInfo } = useContext(CompetitionContext)
  return (
    <div style={{ position: 'absolute', right: '35%' }}>
      <h1> Welcome to Competition {competitionInfo.name}</h1>
      <span>Choose a Test function on the Sidebar </span>
    </div>
  )
}

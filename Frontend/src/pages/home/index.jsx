import React, { useContext } from 'react'
import { CompetitionContext } from '../../api/helper/context/competition_context'

export default function HomePage() {
  const { competitionInfo } = useContext(CompetitionContext)
  return <div style={{ width: '1440px' }}>...</div>
}

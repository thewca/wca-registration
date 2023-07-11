import { createContext } from 'react'
import { CompetitionInfo } from '../../types'

interface CompetitionContext {
  competitionInfo: CompetitionInfo | null
}

export const CompetitionContext = createContext<CompetitionContext>({
  competitionInfo: null,
})

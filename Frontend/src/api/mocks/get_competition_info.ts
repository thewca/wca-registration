import getCompetitionInfo from '../competition/get/get_competition_info'
import { CompetitionInfo } from '../types'
import {
  CLOSED_COMPETITION,
  COMMENT_REQUIRED,
  FAVOURITES_COMPETITION,
  LOW_COMPETITOR_LIMIT,
  NOT_YET_OPEN,
  OPEN_COMPETITION,
  OPEN_WITH_PAYMENTS,
} from './fixtures'

export default async function getCompetitionInfoMockWithRealFallback(
  competitionId: string
): Promise<CompetitionInfo> {
  switch (competitionId) {
    case 'KoelnerKubing2023': {
      return OPEN_COMPETITION
    }
    case 'RheinNeckarAutumn2023': {
      return OPEN_WITH_PAYMENTS
    }
    case 'HessenOpen2023': {
      return CLOSED_COMPETITION
    }
    case 'ManchesterSpring2024': {
      return NOT_YET_OPEN
    }
    case 'FMCFrance2023': {
      return COMMENT_REQUIRED
    }
    case 'PickeringFavouritesAutumn2023': {
      return FAVOURITES_COMPETITION
    }
    case 'LowLimit2023': {
      return LOW_COMPETITOR_LIMIT
    }
    default: {
      // This allows non mocked response when debugging a certain competition
      return getCompetitionInfo(competitionId)
    }
  }
}

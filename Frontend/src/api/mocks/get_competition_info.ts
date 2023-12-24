import getCompetitionInfo from '../competition/get/get_competition_info'
import { CompetitionInfo } from '../types'
import { CLOSED_COMPETITION } from './fixtures/competitions/closed'
import { COMMENT_REQUIRED } from './fixtures/competitions/comment_required'
import { FAVOURITES_COMPETITION } from './fixtures/competitions/favourites'
import { LOW_COMPETITOR_LIMIT } from './fixtures/competitions/low_competitor_limit'
import { MULTI_VENUE } from './fixtures/competitions/multi_venue'
import { NOT_YET_OPEN } from './fixtures/competitions/not_yet_open'
import { OPEN_COMPETITION } from './fixtures/competitions/open'
import { OPEN_WITH_PAYMENTS } from './fixtures/competitions/open_with_payments'
import { SERIES_COMP_1, SERIES_COMP_2 } from './fixtures/competitions/series_competitions'

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
    case 'SeriesComp1': {
      return SERIES_COMP_1
    }
    case 'SeriesComp2': {
      return SERIES_COMP_2
    }
    case 'LowLimit2023': {
      return LOW_COMPETITOR_LIMIT
    } // Doesn't need a backend mock equivalent as the competition is marked as not using wca-registrations
    case 'FMCCanada2023': {
      return MULTI_VENUE
    }
    default: {
      // This allows non mocked response when debugging a certain competition
      return getCompetitionInfo(competitionId)
    }
  }
}

import getCompetitionWcif from '../competition/get/get_competition_wcif'
import { CLOSED_COMPETITION_WCIF } from './fixtures/competitions/closed'
import { COMMENT_REQUIRED_WCIF } from './fixtures/competitions/comment_required'
import { FAVOURITES_COMPETITION_WCIF } from './fixtures/competitions/favourites'
import { LOW_COMPETITOR_LIMIT_WCIF } from './fixtures/competitions/low_competitor_limit'
import { MULTI_VENUE_WCIF } from './fixtures/competitions/multi_venue'
import { NOT_YET_OPEN_WCIF } from './fixtures/competitions/not_yet_open'
import { OPEN_COMPETITION_WCIF } from './fixtures/competitions/open'
import { OPEN_WITH_PAYMENTS_WCIF } from './fixtures/competitions/open_with_payments'
import { EVENT_REGISTRATION_LIMIT_WCIF } from './fixtures/competitions/event_registration_limit'

export default function getWcifMockWithRealFallback(competitionId: string) {
  switch (competitionId) {
    case 'KoelnerKubing2023': {
      return OPEN_COMPETITION_WCIF
    }
    case 'RheinNeckarAutumn2023': {
      return OPEN_WITH_PAYMENTS_WCIF
    }
    case 'HessenOpen2023': {
      return CLOSED_COMPETITION_WCIF
    }
    case 'ManchesterSpring2024': {
      return NOT_YET_OPEN_WCIF
    }
    case 'FMCFrance2023': {
      return COMMENT_REQUIRED_WCIF
    }
    case 'PickeringFavouritesAutumn2023': {
      return FAVOURITES_COMPETITION_WCIF
    }
    case 'LowLimit2023': {
      return LOW_COMPETITOR_LIMIT_WCIF
    } // Doesn't need a backend mock equivalent as the competition is marked as not using wca-registrations
    case 'FMCCanada2023': {
      return MULTI_VENUE_WCIF
    }
    case 'EventRegLimit': {
      return EVENT_REGISTRATION_LIMIT_WCIF 
    }
    default: {
      // This allows non mocked response when debugging a certain competition
      return getCompetitionWcif(competitionId)
    }
  }
}

// This function simulates a call to the user permissions route on the monolith.
// This will return your own permissions, not someone else, the argument is
// just here for the mock
import { USER_IS_BANNED, USER_PROFILE_INCOMPLETE } from '../helper/error_codes'

function getPermissions(userId: string) {
  switch (userId) {
    case '1':
      return {
        can_attend_competitions: {
          scope: '*',
        },
        can_organize_competitions: {
          scope: ['BudapestSummer2023'],
        },
        can_administer_competitions: {
          scope: ['BudapestSummer2023'],
        },
      }
    case '2':
      return {
        can_attend_competitions: {
          scope: '*',
        },
        can_organize_competitions: {
          scope: [],
        },
        can_administer_competitions: {
          scope: [],
        },
      }
    case '6427':
      return {
        can_attend_competitions: {
          scope: '*',
        },
        can_organize_competitions: {
          scope: [],
        },
        can_administer_competitions: {
          scope: [],
        },
      }
    case '15073':
      return {
        can_attend_competitions: {
          scope: '*',
        },
        can_organize_competitions: {
          scope: '*',
        },
        can_administer_competitions: {
          scope: '*',
        },
      }
    case '209943':
      return {
        can_attend_competitions: {
          scope: [],
          reasons: USER_IS_BANNED,
        },
        can_organize_competitions: {
          scope: [],
        },
        can_administer_competitions: {
          scope: [],
        },
      }
    case '999999':
      return {
        can_attend_competitions: {
          scope: [],
          reasons: USER_PROFILE_INCOMPLETE,
        },
        can_organize_competitions: {
          scope: [],
        },
        can_administer_competitions: {
          scope: [],
        },
      }
    default:
      return {
        can_attend_competitions: {
          scope: [],
        },
        can_organize_competitions: {
          scope: [],
        },
        can_administer_competitions: {
          scope: [],
        },
      }
  }
}

export function canAdminCompetition(userId: string, competitionId: string) {
  const permissions = getPermissions(userId)
  return (
    permissions.can_administer_competitions.scope === '*' ||
    (permissions.can_administer_competitions.scope as string[]).includes(
      competitionId
    )
  )
}

export function canAttendCompetitions(userId: string) {
  const permissions = getPermissions(userId)
  return permissions.can_attend_competitions.scope === '*'
}

// TODO: move these to I18n
export const CAN_ADMINISTER_COMPETITIONS = 'Can Administer Competitions'
export const CAN_ATTEND_COMPETITIONS = 'Can attend Competitions'

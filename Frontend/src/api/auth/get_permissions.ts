// This function simulates a call to the user permissions route on the monolith.
// This will return your own permissions, not someone else, the argument is
// just here for the mock
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

export function canAdminCompetition(competitionId: string, userId: string) {
  const permissions = getPermissions(userId)
  return (
    permissions.can_administer_competitions.scope === '*' ||
    (permissions.can_administer_competitions.scope as string[]).includes(
      competitionId
    )
  )
}

export const CAN_ADMINISTER_COMPETITIONS = 'Can Administer Competitions'

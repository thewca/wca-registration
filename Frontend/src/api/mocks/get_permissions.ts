import { USER_KEY } from '../../ui/App'
import { USER_IS_BANNED, USER_PROFILE_INCOMPLETE } from '../helper/error_codes'

export default function getPermissionsMock() {
  const userId = localStorage.getItem(USER_KEY)
  switch (userId) {
    case '1':
      return {
        can_attend_competitions: {
          scope: '*',
        },
        can_organize_competitions: {
          scope: ['BanjaLukaCubeDay2023'],
        },
        can_administer_competitions: {
          scope: ['BanjaLukaCubeDay2023'],
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

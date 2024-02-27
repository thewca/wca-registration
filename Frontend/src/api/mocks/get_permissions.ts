import { Permissions } from '../auth/get_permissions'
import { USER_KEY } from './get_jwt'

export default function getPermissionsMock(): Permissions {
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
          scope: ['KoelnerKubing2023', 'LowLimit2023'],
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

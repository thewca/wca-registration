import { UserFull } from '../helper/context/user_context'
import { USER_KEY } from './get_jwt'

export default function getMeMock(): UserFull | null {
  const userId = localStorage.getItem(USER_KEY)
  switch (userId) {
    case '1':
      return {
        id: 1,
        created_at: '-',
        updated_at: '-',
        name: 'Ron van Bruchem',
        delegate_status: 'delegate',
        gender: 'm',
        country_iso2: 'NL',
        email: '1@worldcubeassociation.org',
        region: 'Netherlands',
        senior_delegate_id: 0,
        class: 'user',
        teams: [],
        wca_id: '2003BRUC01',
        country: {
          id: 'NL',
          name: 'Netherlands',
          iso2: 'NL',
        },
        avatar: {
          url: '-',
          pending_url: '-',
          thumb_url: '-',
        },
      }
    case '2':
      return {
        id: 2,
        created_at: '-',
        updated_at: '-',
        name: 'Sebastien Auroux',
        delegate_status: 'delegate',
        gender: 'm',
        country_iso2: 'DE',
        email: '2@worldcubeassociation.org',
        region: 'Germany',
        senior_delegate_id: 0,
        class: 'user',
        teams: [],
        wca_id: '2008AURO01',
        country: {
          id: 'DE',
          name: 'Germany',
          iso2: 'DE',
        },
        avatar: {
          url: '-',
          pending_url: '-',
          thumb_url: '-',
        },
      }
    case '6427':
      return {
        id: 6427,
        created_at: '-',
        updated_at: '-',
        name: 'Joey Gouly',
        delegate_status: '',
        gender: 'm',
        country_iso2: 'UK',
        email: '6427@worldcubeassociation.org',
        region: 'United Kingdom',
        senior_delegate_id: 0,
        class: 'user',
        teams: [],
        wca_id: '2007GOUL01',
        country: {
          id: 'UK',
          name: 'United Kingdom',
          iso2: 'UK',
        },
        avatar: {
          url: '-',
          pending_url: '-',
          thumb_url: '-',
        },
      }
    case '15073':
      return {
        id: 15073,
        created_at: '-',
        updated_at: '-',
        name: 'Finn Ickler',
        delegate_status: '',
        gender: 'm',
        country_iso2: 'DE',
        email: '15073@worldcubeassociation.org',
        region: 'Germany',
        senior_delegate_id: 0,
        class: 'user',
        teams: [],
        wca_id: '2012ICKL01',
        country: {
          id: 'DE',
          name: 'Germany',
          iso2: 'DE',
        },
        avatar: {
          url: '-',
          pending_url: '-',
          thumb_url: '-',
        },
      }
    case '209943':
      return {
        id: 209943,
        created_at: '-',
        updated_at: '-',
        name: 'Banny McBannington',
        delegate_status: '',
        gender: 'm',
        country_iso2: 'BL',
        email: '209943@worldcubeassociation.org',
        region: 'Banland',
        senior_delegate_id: 0,
        class: 'user',
        teams: [],
        wca_id: '2099BANN01',
        country: {
          id: 'BL',
          name: 'Ban Land',
          iso2: 'BL',
        },
        avatar: {
          url: '-',
          pending_url: '-',
          thumb_url: '-',
        },
      }
    case '999999':
      return {
        id: 999999,
        created_at: '-',
        updated_at: '-',
        name: 'Baby User',
        delegate_status: '',
        gender: 'f',
        country_iso2: 'BB',
        email: '999999@worldcubeassociation.org',
        region: 'The Bed',
        senior_delegate_id: 0,
        class: 'user',
        teams: [],
        wca_id: '',
        country: {
          id: 'BB',
          name: 'Baby Land',
          iso2: 'BB',
        },
        avatar: {
          url: '-',
          pending_url: '-',
          thumb_url: '-',
        },
      }
    default:
      return null
  }
}

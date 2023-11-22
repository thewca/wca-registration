import { EventId } from '@wca/helpers'

interface Tabs {
  id: number
  competition_id: string
  name: string
  content: string
  display_order: number
}

// This needs to be moved to WCA-helpers
interface CompetitionInfo {
  'id': string
  'name': string
  'information': string
  'registration_open': string
  'registration_close': string
  'announced_at': string
  'start_date': string
  'end_date': string
  'competitor_limit'?: number
  'cancelled_at'?: string
  'refund_policy_limit_date'?: string
  'refund_policy_percent'?: number
  'event_change_deadline_date'?: string
  'waiting_list_deadline_date'?: string
  'base_entry_fee_lowest_denomination'?: number
  'currency_code'?: string
  'on_the_spot_registration': boolean
  'on_the_spot_entry_fee_lowest_denomination'?: number
  'extra_registration_requirements': string
  'guests_entry_fee_lowest_denomination': number
  'url': string
  'qualification_results': boolean
  'event_restrictions': boolean
  'website': string
  'short_name': string
  'city': string
  'enable_donations': boolean
  'venue': string
  'venue_address': string
  'force_comment_in_registration': boolean
  'venue_details'?: string
  'latitude_degrees': number
  'longitude_degrees': number
  'number_of_bookmarks': number
  'country_iso2': string
  'registration_opened?': boolean
  'use_wca_registration': boolean
  'uses_qualification?': boolean
  'uses_cutoff?': boolean
  'using_stripe_payments?'?: boolean
  'external_registration_page'?: string
  'event_ids': EventId[]
  'main_event_id'?: EventId
  'guests_per_registration_limit'?: number
  'guest_entry_status': 'free' | 'restricted' | 'unclear'
  'allow_registration_edits': boolean
  'allow_registration_without_qualification': boolean
  'allow_registration_self_delete_after_acceptance': boolean
  'delegates': UserFull[]
  'organizers': UserFull[]
  'contact': string
  'tabs': Tabs[]
  'class': string
}

interface CompetitionEvent {
  id: number
  competition_id: string
  event_id: EventId
  fee_lowest_denomination: number
  qualification: object
}

interface UserFull {
  id: number
  created_at: string
  updated_at: string
  name: string
  delegate_status?: string
  gender: 'm' | 'f' | 'o'
  country_iso2: string
  location?: string
  email?: string
  region?: string
  senior_delegate_id?: number
  class: string
  url: string
  teams: {
    id: number
    friendly_id: string
    leader: boolean
    name: string
    senior_member: boolean
    wca_id: string
    avatar: {
      url: string
      thumb: {
        url: string
      }
    }
  }[]
  wca_id?: string
  country: {
    continentId: string
    id: string
    name: string
    iso2: string
  }
  avatar: {
    url: string
    pending_url: string
    thumb_url: string
    is_default: boolean
  }
}

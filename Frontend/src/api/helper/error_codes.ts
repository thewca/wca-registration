// see app/helpers/error_codes.rb
// TODO generate these errors out of some kind of shared error file
export const INVALID_TOKEN = -1
export const EXPIRED_TOKEN = -2
export const MISSING_AUTHENTICATION = -3
export const SERVICE_DOWN = -4

export const COMPETITION_NOT_FOUND = -1000
export const COMPETITION_API_5XX = -1001
export const COMPETITION_CLOSED = -1002
export const COMPETITION_INVALID_EVENTS = -1003

export const USER_IMPERSONATION = -2000
export const USER_IS_BANNED = -2001
export const USER_PROFILE_INCOMPLETE = -2002
export const USER_INSUFFICIENT_PERMISSIONS = -2003
export const USER_NOT_LOGGED_IN = -2004

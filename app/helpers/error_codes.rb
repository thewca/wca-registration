# frozen_string_literal: true

module ErrorCodes
  # System Errors
  INVALID_TOKEN = -1
  EXPIRED_TOKEN = -2
  MISSING_AUTHENTICATION = -3

  # Competition Errors
  COMPETITION_NOT_FOUND = -1000
  COMPETITION_API_5XX = -1001
  COMPETITION_CLOSED = -1002
  COMPETITION_INVALID_EVENTS = -1003

  # User Errors
  USER_IMPERSONATION = -2000
  USER_IS_BANNED = -2001
  USER_PROFILE_INCOMPLETE = -2002
  USER_INSUFFICIENT_PERMISSIONS = -2003

  # Registration errors
  REGISTRATION_NOT_FOUND = -3000

  # Request errors
  INVALID_REQUEST_DATA = -4000
  EVENT_EDIT_DEADLINE_PASSED = -4001
  GUEST_LIMIT_EXCEEDED = -4002
  USER_COMMENT_TOO_LONG = -4003
  INVALID_EVENT_SELECTION = -4004
  REQUIRED_COMMENT_MISSING = -4005
  COMPETITOR_LIMIT_REACHED = -4006
end

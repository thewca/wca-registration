export const tokenRoute = `${process.env.WCA_URL}/api/v0/users/me/token`
export const permissionsRoute = `${process.env.WCA_URL}/api/v0/users/me/permissions`
export const paymentConfigRoute = (competitionId: string, paymentId: string) =>
  `${process.env.WCA_URL}/payment/config?competition_id=${competitionId}&payment_id=${paymentId}`
export const paymentFinishRoute = (competitionId: string, userId: string) =>
  `${process.env.WCA_URL}/payment/finish?attendee_id=${competitionId}-${userId}`

export const availableRefundsRoute = (competitionId: string, userId: string) =>
  `${process.env.WCA_URL}/payment/refunds?attendee_id=${competitionId}-${userId}`

export const bookmarkCompetitionRoute = `${process.env.WCA_URL}/competitions/bookmark`

export const unbookmarkCompetitionRoute = `${process.env.WCA_URL}/competitions/unbookmark`

export const refundRoute = (
  competitionId: string,
  userId: string,
  paymentId: string,
  amount: number,
) =>
  `${process.env.WCA_URL}/payment/refund?attendee_id=${competitionId}-${userId}&payment_id=${paymentId}&refund_amount=${amount}`

export const userProfileRoute = (wcaId: string) =>
  `${process.env.WCA_URL}/persons/${wcaId}`

export const competitionsPDFRoute = (compId: string) =>
  `${process.env.WCA_URL}/competitions/${compId}.pdf`

export const competitionContactFormRoute = (compId: string) =>
  `https://www.worldcubeassociation.org/contact/website?competitionId=${compId}`

export const pollingRoute = (userId: string, competitionId: string) =>
  `${process.env.POLL_URL}?attendee_id=${competitionId}-${userId}`
export const meRoute = `${process.env.WCA_URL}/api/v0/users/me`

export const preferredEventsRoute = `${process.env.WCA_URL}/api/v0/users/me/preferred_events`

export const myBookmarkedCompetitionsRoute = `${process.env.WCA_URL}/api/v0/users/me/bookmarks`

export const competitionInfoRoute = (id: string) =>
  `${process.env.WCA_URL}/api/v0/competitions/${id}`
export const competitionWCIFRoute = (id: string) =>
  `${process.env.WCA_URL}/api/v0/competitions/${id}/wcif/public`
export const userInfoRoute = (id: string) =>
  `${process.env.WCA_URL}/api/v0/users/${id}`

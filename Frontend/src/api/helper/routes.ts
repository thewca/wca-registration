export const tokenRoute = `${process.env.WCA_URL}/api/v0/users/token`
export const permissionsRoute = `${process.env.WCA_URL}/api/v0/users/me/permissions`
export const paymentConfigRoute = `${process.env.WCA_URL}/payment/config`
export const paymentFinishRoute = (competitionId: string, userId: string) =>
  `${process.env.WCA_URL}/payment/${competitionId}-${userId}/finish`
export const pollingRoute = (userId: string, competitionId: string) =>
  `${process.env.POLL_URL}?attendee_id=${competitionId}-${userId}`
export const meRoute = `${process.env.WCA_URL}/api/v0/users/me`
// This will break when urls get really big, maybe we should switch to POST?
export const usersInfoRoute = (ids: string[]) =>
  `${process.env.WCA_URL}/api/v0/users?${ids
    .map((id) => 'ids[]=' + id)
    .join('&')}`
export const competitionInfoRoute = (id: string) =>
  `${process.env.WCA_URL}/api/v0/competitions/${id}`
export const competitionWCIFRoute = (id: string) =>
  `${process.env.WCA_URL}/api/v0/competitions/${id}/wcif/public`
export const userInfoRoute = (id: string) =>
  `${process.env.WCA_URL}/api/v0/users/${id}`

export const tokenRoute = `${process.env.WCA_URL}/api/v0/users/token`
export const permissionsRoute = `${process.env.WCA_URL}/api/v0/users/me/permissions`
export const paymentConfigRoute = `${process.env.WCA_URL}/payment/config`
export const paymentFinishRoute = (competitionId: string, userId: string) =>
  `${process.env.WCA_URL}/payment/${competitionId}-${userId}/finish`
// TODO: Move this to swagger once finalised
export const paymentIdRoute = (id: string) =>
  `${process.env.API_URL}/${id}/payment`
export const meRoute = `${process.env.WCA_URL}/api/v0/users/me`
// This will break when urls get really big, maybe we should switch to POST?
export const usersInfoRoute = (ids: string[]) =>
  `${process.env.WCA_URL}/api/v0/users?${ids
    .map((id) => 'ids[]=' + id)
    .join('&')}`
// Hardcoded because these are currently not mocked
export const competitionInfoRoute = (id: string) =>
  `https://api.worldcubeassociation.org/competitions/${id}`
export const competitionWCIFRoute = (id: string) =>
  `https://api.worldcubeassociation.org/competitions/${id}/wcif/public`
export const userInfoRoute = (id: string) =>
  `https://api.worldcubeassociation.org/users/${id}`

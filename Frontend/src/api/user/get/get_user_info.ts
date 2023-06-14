import externalServiceFetch from '../../helper/external_service_fetch'

interface CompetitorInfo {
  user: {
    id: string
    wca_id: string
    name: string
    country: {
      id: string
      name: string
      iso2: string
    }
  }
}

export default async function getCompetitorInfo(
  userId: string
): Promise<CompetitorInfo> {
  return externalServiceFetch(
    `https://www.worldcubeassociation.org/api/v0/users/${userId}`
  )
}

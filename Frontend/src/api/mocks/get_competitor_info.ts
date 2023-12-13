import { getAllRegistrations } from '../registration/get/get_registrations'
import { CompetitorInfo } from '../types'

export default async function getCompetitorInfoMock(competitionId: string) {
  const registrations = await getAllRegistrations(competitionId)
  return registrations.map((r) => competitorInfoMock(r.user_id))
}

function competitorInfoMock(userId: string): CompetitorInfo {
  return {
    id: Number(userId),
    wca_id: '2099XX01',
    name: 'Test Testerton',
    email: userId + '@worldcubeassociation.org',
    dob: new Date('1950 07 01').toLocaleDateString(),
    gender: 'o',
    country_iso2: 'en',
  }
}

import { getJWT } from '../../auth/get_jwt'

export default async function importRegistration(body: {
  competitionId: string
  file: File
}): Promise<{ status: string }> {
  const formData = new FormData()
  formData.append('csv_data', body.file)
  const response = await fetch(
    `${process.env.API_URL}/${body.competitionId}/import`,
    {
      method: 'POST',
      body: formData,
      headers: {
        Authorization: await getJWT(),
      },
    },
  )
  return response.json()
}

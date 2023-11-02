export default async function importRegistration(body: {
  competitionId: string
  file: File
}): Promise<{ status: string }> {
  const formData = new FormData()
  formData.append('file', body.file)
  formData.append('fileName', body.file.name)
  const response = await fetch(`/${body.competitionId}/import`, {
    method: 'POST',
    body: formData,
    headers: {
      'Content-Type': 'multipart/formData',
    },
  })
  return response.json()
}

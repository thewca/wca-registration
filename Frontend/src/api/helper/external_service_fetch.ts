export default async function externalServiceFetch(route: string) {
  try {
    const response = await fetch(route)

    if (response.ok) {
      return await response.json()
    }
    return { error: response.statusText, statusCode: response.status }
  } catch (error) {
    return { error, statusCode: 500 }
  }
}

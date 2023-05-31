type Method = 'POST' | 'GET' | 'PATCH' | 'DELETE'

type Body =
  | SubmitRegistrationBody
  | UpdateRegistrationBody
  | GetRegistrationBody
  | DeleteRegistrationBody

export default async function backendFetch(
  route: string,
  method: Method,
  body: Body = {}
) {
  try {
    let init = {}
    if (method !== 'GET') {
      init = {
        method,
        body: JSON.stringify(body),
        headers: {
          'Content-Type': 'application/json',
        },
      }
    }
    const response = await fetch(`${process.env.API_URL}/${route}`, init)

    if (response.ok) {
      return await response.json()
    }
    return { error: response.statusText, statusCode: response.status }
  } catch (error) {
    return { error, statusCode: 500 }
  }
}

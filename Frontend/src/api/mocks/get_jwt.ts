export const USER_KEY = 'user'

export default async function getJWTMock(): Promise<string> {
  const user = localStorage.getItem(USER_KEY)
  const response = await fetch(`${process.env.AUTH_URL}/${user}`)
  const data = await response.json()
  return `Bearer: ${data.token}`
}

import backendFetch from '../../helper/backend_fetch'
import { SubmitRegistrationBody } from '../../types'

export default async function submitEventRegistration(
  body: SubmitRegistrationBody
) {
  return backendFetch('/register', 'POST', {
    body,
    needsAuthentication: true,
  })
}

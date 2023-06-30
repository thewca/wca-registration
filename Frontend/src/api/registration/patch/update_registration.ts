import backendFetch from '../../helper/backend_fetch'
import { UpdateRegistrationBody } from '../../types'
import { RegistrationAdmin } from '../get/get_registrations'

export async function updateRegistration(body: UpdateRegistrationBody) {
  return backendFetch('/register', 'PATCH', {
    body,
    needsAuthentication: true,
  }) as Promise<{ registration: RegistrationAdmin }>
}

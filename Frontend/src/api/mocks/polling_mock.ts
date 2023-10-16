import { RegistrationStatus } from '../registration/get/poll_registrations'

export default function pollingMock(): RegistrationStatus {
  // Currently randomly returning to simulate processing time
  const competingStatus = Math.random() > 0.9 ? 'processing' : 'pending'
  return {
    status: {
      competing: competingStatus,
      payment: 'none',
    },
    queue_count: Math.round(Math.random() * 10),
  }
}

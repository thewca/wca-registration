import { RegistrationStatus } from '../registration/get/poll_registrations'

export default function pollingMock(): RegistrationStatus {
  // Currently randomly returning to simulate processing time
  const competingStatus = Math.random() > 0.4 ? 'processing' : 'incoming'
  return {
    status: {
      competing: competingStatus,
      payment: 'none',
    },
    queue_count: Math.round(Math.random() * 10),
  }
}

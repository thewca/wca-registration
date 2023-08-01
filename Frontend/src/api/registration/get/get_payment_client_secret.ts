import backendFetch from '../../helper/backend_fetch'

interface PaymentInfo {
  client_secret_id: string
  connected_account_id: string
}
// We get the user_id out of the JWT key, which is why we only send the
// competition_id
export default async function getPaymentInfo(
  competitionId: string
): Promise<PaymentInfo> {
  return backendFetch(`/${competitionId}/payment`, 'GET', {
    needsAuthentication: true,
  }) as Promise<PaymentInfo>
}

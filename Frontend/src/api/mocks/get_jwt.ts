import Base64 from 'crypto-js/enc-base64'
import md5 from 'crypto-js/md5'
import * as jose from 'jose'
import { USER_KEY } from '../../ui/UserProvider'

export default async function getJWTMock(): Promise<string> {
  const user = localStorage.getItem(USER_KEY)
  const secret = new TextEncoder().encode('jwt-test-secret')
  const alg = 'HS256'
  const issuedAt = Date.now()
  const jwt = await new jose.SignJWT({ data: { user_id: user } })
    .setProtectedHeader({ alg })
    .setIssuedAt(issuedAt)
    .setJti(Base64.stringify(md5(`${secret}:${issuedAt}`)))
    .setIssuer('wca-registration-test-frontend')
    .setAudience('wca-registration-test-backend')
    .setExpirationTime('30m')
    .sign(secret)
  return `Bearer: ${jwt}`
}

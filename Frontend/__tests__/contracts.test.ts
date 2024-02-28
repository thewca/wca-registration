import { describe, expect, test } from '@jest/globals'
import { paths } from '../src/api/validations'
import { paths as API } from '../src/api/schema'
import createClient from 'openapi-fetch'
import { getJWT } from '../src/api/auth/get_jwt'
import { USER_KEY } from '../src/api/mocks/get_jwt'

// If environment variables aren't set, revert to testing values
process.env.API_URL = process.env.API_URL ?? 'http://10.0.2.10:3000'
process.env.AUTH_URL = process.env.AUTH_URL ?? 'http://10.0.2.10:3000/test/jwt'

const { POST, GET } = createClient<API>({
  baseUrl: process.env.API_URL,
})

describe('/api/v1/users', () => {
  describe('GET', () => {
    test('Correct Success Response', async () => {
      const { data } = await POST('/api/v1/users', {
        body: { ids: [1] },
      })
      const validation =
        paths['/api/v1/users'].post.responses['200'].content[
          'application/json'
        ].safeParse(data)
      expect(validation.success).toBe(true)
    })
  })
})

describe('/api/v1/registrations/{competition_id}', () => {
  describe('GET', () => {
    test('Correct Success Response', async () => {
      const { data } = await GET('/api/v1/registrations/{competition_id}', {
        params: { path: { competition_id: 'KoelnerKubing2023' } },
      })
      const validation =
        paths['/api/v1/registrations/{competition_id}'].get.responses[
          '200'
        ].content['application/json'].safeParse(data)
      expect(validation.success).toBe(true)
    })
  })
})

describe('/api/v1/registrations/{competition_id}/waiting', () => {
  describe('GET', () => {
    test('Correct Success Response', async () => {
      // "Log In" by setting localstorage
      localStorage.setItem(USER_KEY, '1')
      const { data } = await GET(
        '/api/v1/registrations/{competition_id}/waiting',
        {
          params: { path: { competition_id: 'KoelnerKubing2023' } },
          headers: { Authorization: await getJWT() },
        },
      )
      const validation =
        paths['/api/v1/registrations/{competition_id}/waiting'].get.responses[
          '200'
        ].content['application/json'].safeParse(data)
      expect(validation.success).toBe(true)
    })
  })
})

describe('/api/v1/psych_sheet/{competition_id}/{event_id}', () => {
  describe('GET', () => {
    test('Correct Success Response', async () => {
      const { data } = await GET(
        '/api/v1/psych_sheet/{competition_id}/{event_id}',
        {
          params: {
            path: { competition_id: 'KoelnerKubing2023', event_id: '333' },
          },
        },
      )
      const validation =
        paths['/api/v1/psych_sheet/{competition_id}/{event_id}'].get.responses[
          '200'
        ].content['application/json'].safeParse(data)
      expect(validation.success).toBe(true)
    })
  })
})

describe('/api/v1/registrations/{competition_id}/admin', () => {
  describe('GET', () => {
    test('Correct Success Response', async () => {
      // "Log In" by setting localstorage
      localStorage.setItem(USER_KEY, '2')
      const { data } = await GET(
        '/api/v1/registrations/{competition_id}/admin',
        {
          params: { path: { competition_id: 'KoelnerKubing2023' } },
          headers: { Authorization: await getJWT() },
        },
      )
      const validation =
        paths['/api/v1/registrations/{competition_id}/admin'].get.responses[
          '200'
        ].content['application/json'].safeParse(data)
      expect(validation.success).toBe(true)
    })

    test('Correct Error Response without Authorization', async () => {
      const { error } = await GET(
        '/api/v1/registrations/{competition_id}/admin',
        {
          params: { path: { competition_id: 'KoelnerKubing2023' } },
        },
      )
      const validation =
        paths['/api/v1/registrations/{competition_id}/admin'].get.responses[
          '401'
        ].content['application/json'].safeParse(error)
      expect(validation.success).toBe(true)
    })

    test('Correct Error Response for Unauthorized User', async () => {
      // "Log In" by setting localstorage
      localStorage.setItem(USER_KEY, '1')
      const { error } = await GET(
        '/api/v1/registrations/{competition_id}/admin',
        {
          params: { path: { competition_id: 'KoelnerKubing2023' } },
          headers: { Authorization: await getJWT() },
        },
      )
      const validation =
        paths['/api/v1/registrations/{competition_id}/admin'].get.responses[
          '401'
        ].content['application/json'].safeParse(error)
      expect(validation.success).toBe(true)
    })
  })
})

describe('/api/v1/register', () => {
  describe('GET', () => {
    test('Correct Success Response', async () => {
      // "Log In" by setting localstorage
      localStorage.setItem(USER_KEY, '9001')
      const { data } = await GET('/api/v1/register', {
        params: {
          query: { competition_id: 'KoelnerKubing2023', user_id: 9001 },
        },
        headers: { Authorization: await getJWT() },
      })
      const validation =
        paths['/api/v1/register'].get.responses['200'].content[
          'application/json'
        ].safeParse(data)
      expect(validation.success).toBe(true)
    })

    test('Correct Error Response without Authorization', async () => {
      const { error } = await GET('/api/v1/register', {
        params: {
          query: { competition_id: 'KoelnerKubing2023', user_id: 9001 },
        },
      })
      const validation =
        paths['/api/v1/register'].get.responses['401'].content[
          'application/json'
        ].safeParse(error)
      expect(validation.success).toBe(true)
    })

    test('Correct Error Response for Unauthorized User', async () => {
      // "Log In" by setting localstorage
      localStorage.setItem(USER_KEY, '1')
      const { error } = await GET('/api/v1/register', {
        params: {
          query: { competition_id: 'KoelnerKubing2023', user_id: 9001 },
        },
        headers: { Authorization: await getJWT() },
      })
      const validation =
        paths['/api/v1/register'].get.responses['403'].content[
          'application/json'
        ].safeParse(error)
      expect(validation.success).toBe(true)
    })
  })
})

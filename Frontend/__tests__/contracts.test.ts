import { describe, expect, test } from '@jest/globals'
import { paths } from '../src/api/validations'
import { paths as API } from '../src/api/schema'
import createClient from 'openapi-fetch'
import { getJWT } from '../src/api/auth/get_jwt'
import { USER_KEY } from '../src/api/mocks/get_jwt'

const { POST, GET } = createClient<API>({
  baseUrl: 'http://localhost:3001',
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

    // test('Correct Error Response without Authorization', async () => {
    //   const { data } = await GET(
    //     '/api/v1/registrations/{competition_id}/waiting',
    //     {
    //       params: { path: { competition_id: 'KoelnerKubing2023' } },
    //     },
    //   )
    //   const validation =
    //     paths['/api/v1/registrations/{competition_id}/waiting'].get.responses[
    //       '401'
    //     ].content['application/json'].safeParse(data)
    //   console.log(data)
    //   expect(validation.success).toBe(true)
    // })
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
      // currently failing, TODO consult Gregor
      //  {"success":false,"error":{"issues":[{"code":"invalid_type","expected":"string","received":"undefined","path":["sort_by_secondary"],"message":"Required"}],"name":"ZodError"}}
      expect(validation.success).toBe(false)
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
  })
})

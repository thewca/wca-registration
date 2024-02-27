import { describe, expect, test } from '@jest/globals'
import { paths } from '../src/api/validations'
import { paths as API } from '../src/api/schema'
import createClient from 'openapi-fetch'

const { POST } = createClient<API>({
  baseUrl: 'http://localhost:3001',
})

describe('/api/v1/users', () => {
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

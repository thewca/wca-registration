import React, { useEffect } from 'react'
import { Link, useParams } from 'react-router-dom'
import { USER_KEY } from '../../ui/providers/UserProvider'

export default function TestLogin() {
  const { login_id } = useParams()
  useEffect(() => localStorage.setItem(USER_KEY, login_id), [login_id])
  return (
    <div style={{ position: 'absolute', right: '35%' }}>
      <h1> Successfully 'logged in' as User with the id {login_id}</h1>
      <Link to="/">Back to Home</Link>
    </div>
  )
}

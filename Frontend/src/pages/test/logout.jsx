import React, { useEffect } from 'react'
import { Link } from 'react-router-dom'
import { USER_KEY } from '../../ui/UserProvider'

export default function TestLogout() {
  useEffect(() => localStorage.removeItem(USER_KEY), [])
  return (
    <div style={{ position: 'absolute', right: '35%' }}>
      <h1> Successfully 'logged out' </h1>
      <Link to="/">Back to Home</Link>
    </div>
  )
}

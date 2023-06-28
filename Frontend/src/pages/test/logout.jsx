import React, { useContext, useEffect } from 'react'
import { Link } from 'react-router-dom'
import { AuthContext } from '../../api/helper/context/auth_context'

export default function TestLogout() {
  const { setUser } = useContext(AuthContext)
  useEffect(() => setUser(null), [setUser])
  return (
    <div style={{ position: 'absolute', right: '35%' }}>
      <h1> Successfully 'logged out' </h1>
      <Link to="/">Back to Home</Link>
    </div>
  )
}

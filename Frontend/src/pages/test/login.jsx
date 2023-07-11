import React, { useContext, useEffect } from 'react'
import { Link, useParams } from 'react-router-dom'
import { AuthContext } from '../../api/helper/context/auth_context'

export default function TestLogin() {
  const { login_id } = useParams()
  const { setUser } = useContext(AuthContext)
  useEffect(() => setUser(login_id), [login_id, setUser])
  return (
    <div style={{ position: 'absolute', right: '35%' }}>
      <h1> Successfully 'logged in' as User with the id {login_id}</h1>
      <Link to="/">Back to Home</Link>
    </div>
  )
}

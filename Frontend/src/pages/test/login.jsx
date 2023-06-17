import React from 'react'
import { Link, useParams } from 'react-router-dom'

export default function TestLogin() {
  const { login_id } = useParams()
  return (
    <div style={{ position: 'absolute', right: '35%' }}>
      <h1> Successfully 'logged in' as User with the id {login_id}</h1>
      {setTimeout(() => {
        localStorage.setItem('user_id', login_id)
      }, 100)}
      <Link to="/">Back to Home</Link>
    </div>
  )
}

import React from 'react'
import { useParams } from 'react-router-dom'

export default function HomePage() {
  const { competition_id } = useParams()
  return (
    <div style={{ position: 'absolute', right: '35%' }}>
      <h1> Welcome to Competition {competition_id}</h1>
      <span>Choose a Test function on the Sidebar </span>
    </div>
  )
}

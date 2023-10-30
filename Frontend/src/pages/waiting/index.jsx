import React from 'react'
import { Header } from 'semantic-ui-react'
import WaitingList from './components/WaitingList'

export default function Registrations() {
  return (
    <div>
      <Header>Competitors:</Header>
      <WaitingList />
    </div>
  )
}

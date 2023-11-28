import React from 'react'
import { Header } from 'semantic-ui-react'
import WaitingList from './components/WaitingList'

export default function Waiting() {
  return (
    <div>
      <Header>Waiting List:</Header>
      <WaitingList />
    </div>
  )
}

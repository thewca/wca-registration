import React from 'react'
import { Header, Segment } from 'semantic-ui-react'
import WaitingList from './components/WaitingList'

export default function Waiting() {
  return (
    <Segment padded attached>
      <Header>Waiting List:</Header>
      <WaitingList />
    </Segment>
  )
}

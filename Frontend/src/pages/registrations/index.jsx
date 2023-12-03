import React from 'react'
import RegistrationList from './components/RegistrationList'
import { Segment } from "semantic-ui-react";

export default function Registrations() {
  return (
    <Segment padded attached>
      <RegistrationList />
    </Segment>
  )
}

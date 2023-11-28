import React from 'react'
import { Header } from 'semantic-ui-react'
import RegistrationList from './components/RegistrationList'

export default function Registrations() {
  return (
    <div>
      <Header>Competitors:</Header>
      <RegistrationList />
    </div>
  )
}

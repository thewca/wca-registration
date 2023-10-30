import React from 'react'
import RegistrationList from './components/RegistrationList'
import { Header } from "semantic-ui-react";

export default function Registrations() {
  return (
    <div>
      <Header>Competitors:</Header>
      <RegistrationList />
    </div>
  )
}

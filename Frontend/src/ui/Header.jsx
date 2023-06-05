import { Header } from '@thewca/wca-components'
import React from 'react'
import logo from '../static/wca2020.svg'

const DROPDOWNS = [
  {
    active: true,
    icon: 'sign list ul',
    title: 'Registration System',
    items: [
      {
        path: '/register',
        icon: 'sign in alt',
        title: 'Register',
      },
      {
        path: '/registrations',
        icon: 'users',
        title: 'Competitors',
      },
    ],
  },
]

export default function PageHeader({}) {
  return <Header brandImage={logo} dropdowns={DROPDOWNS} />
}

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
        path: '/BudapestSummer2023',
        icon: 'frog',
        title: 'Test Competition 1',
      },
      {
        path: '/HessenOpen203',
        icon: 'fish',
        title: 'Test Competition 2',
      },
    ],
  },
]

export default function PageHeader() {
  return <Header brandImage={logo} dropdowns={DROPDOWNS} />
}

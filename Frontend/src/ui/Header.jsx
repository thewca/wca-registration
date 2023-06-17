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
        path: '/HessenOpen2023',
        icon: 'fish',
        title: 'Test Competition 2',
      },
    ],
  },
  {
    active: true,
    icon: 'sign list ul',
    title: 'Choose Test User',
    items: [
      {
        path: '/login/6427',
        icon: 'cat',
        title: 'Test Competitor 1',
      },
      {
        path: '/login/2',
        icon: 'horse',
        title: 'Test Competitor 2',
      },
      {
        path: '/login/1',
        icon: 'dog',
        title: 'Test Organizer 1',
      },
      {
        path: '/login/15073',
        icon: 'otter',
        title: 'Test Admin 1',
      },
    ],
  },
]

export default function PageHeader() {
  return <Header brandImage={logo} dropdowns={DROPDOWNS} />
}

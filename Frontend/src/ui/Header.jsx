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
        path: '/competitions/BanjaLukaCubeDay2023',
        icon: 'frog',
        title: 'Test Competition 1',
        reactRoute: true,
      },
      {
        path: '/competitions/DarmstadtDodecahedronDays2023',
        icon: 'fish',
        title: 'Test Competition 2',
        reactRoute: true,
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
        reactRoute: true,
      },
      {
        path: '/login/2',
        icon: 'horse',
        title: 'Test Competitor 2',
        reactRoute: true,
      },
      {
        path: '/login/1',
        icon: 'dog',
        title: 'Organizer of Test Competition 1',
        reactRoute: true,
      },
      {
        path: '/login/15073',
        icon: 'otter',
        title: 'Test Admin',
        reactRoute: true,
      },
      {
        path: '/login/209943',
        icon: 'skull',
        title: 'Test Banned User',
        reactRoute: true,
      },
      {
        path: '/login/999999',
        icon: 'baby',
        title: 'Test Incomplete User',
        reactRoute: true,
      },
    ],
  },
]

export default function PageHeader() {
  return <Header brandImage={logo} dropdowns={DROPDOWNS} />
}

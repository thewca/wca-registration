import { Header } from '@thewca/wca-components'
import React from 'react'
import { BASE_ROUTE } from '../routes'
import logo from '../static/wca2020.svg'

const DROPDOWNS = [
  {
    active: true,
    icon: 'sign list ul',
    title: 'Registration System',
    items: [
      {
        path: `${BASE_ROUTE}/KoelnerKubing2023`,
        icon: 'frog',
        title: 'Open Competition',
        reactRoute: true,
      },
      {
        path: `${BASE_ROUTE}/RheinNeckarAutumn2023`,
        icon: 'fish',
        title: 'Open Competition with Payments',
        reactRoute: true,
      },
      {
        path: `${BASE_ROUTE}/FMCFrance2023`,
        icon: 'pen',
        title: 'Comments Enforced',
        reactRoute: true,
      },
      {
        path: `${BASE_ROUTE}/PickeringFavouritesAutumn2023`,
        icon: 'heart',
        title: 'Favourites Competition',
        reactRoute: true,
      },
      {
        path: `${BASE_ROUTE}/HessenOpen2023`,
        icon: 'close',
        title: 'Closed Competition',
        reactRoute: true,
      },
      {
        path: `${BASE_ROUTE}/ManchesterSpring2024`,
        icon: 'time',
        title: 'Not yet open Competition',
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
        path: '/login/1',
        icon: 'horse',
        title: 'Test Competitor 2',
        reactRoute: true,
      },
      {
        path: '/login/2',
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
      {
        path: '/logout',
        icon: 'sign out',
        title: 'Log Out',
        reactRoute: true,
      },
    ],
  },
]

export default function PageHeader() {
  return <Header brandImage={logo} dropdowns={DROPDOWNS} />
}

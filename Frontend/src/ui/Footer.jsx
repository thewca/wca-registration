import { Footer } from '@thewca/wca-components'
import React from 'react'

const LINKS = [
  {
    title: 'Main Website',
    path: 'https://www.worldcubeassocation.org',
  },
  {
    title: 'Github',
    path: 'https://github.com/thewca/wca-registration',
    cssClass: 'hide-new-window-icon',
    target: '_blank',
    icon: true,
  },
]

export default function PageFooter({}) {
  return <Footer links={LINKS} />
}

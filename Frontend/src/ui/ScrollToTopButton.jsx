import React, { useEffect, useState } from 'react'
import { Icon } from 'semantic-ui-react'

const scrollYBreakpoint = 300

export default function ScrollToTopButton() {
  const [isShowing, setIsShowing] = useState(false)

  const scrollToTop = () => window.scrollTo({ top: 0, behavior: 'smooth' })

  useEffect(() => {
    const updateShowing = () => setIsShowing(window.scrollY > scrollYBreakpoint)

    window.addEventListener('scroll', updateShowing)

    return () => window.removeEventListener('scroll', updateShowing)
  }, [])

  // TODO: absolute positioning
  return isShowing && <Icon link onClick={scrollToTop} name="arrow up" />
}

import React, { useEffect, useState } from 'react'
import { Button } from 'semantic-ui-react'

const scrollYBreakpoint = 300

export default function ScrollToTopButton() {
  const [isBeyondBreakpoint, setIsBeyondBreakpoint] = useState(false)

  useEffect(() => {
    const updateShowing = () =>
      setIsBeyondBreakpoint(window.scrollY > scrollYBreakpoint)

    window.addEventListener('scroll', updateShowing)

    return () => window.removeEventListener('scroll', updateShowing)
  }, [])

  const scrollToTop = () => window.scrollTo({ top: 0, behavior: 'smooth' })

  return (
    isBeyondBreakpoint && (
      <Button
        icon="up arrow"
        floated="right"
        color="purple"
        style={{
          zIndex: 5000,
          position: 'fixed',
          bottom: '55px',
          right: '10px',
        }}
        onClick={scrollToTop}
      />
    )
  )
}

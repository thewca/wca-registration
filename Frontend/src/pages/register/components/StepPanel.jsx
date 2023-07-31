import React, { useContext, useMemo, useState } from 'react'
import { Tab } from 'semantic-ui-react'
import { CompetitionContext } from '../../../api/helper/context/competition_context'
import CompetingStep from './CompetingStep'
import StripeWrapper from './StripeWrapper'

export default function StepPanel() {
  const { competitionInfo } = useContext(CompetitionContext)
  // const [currentStep, setCurrentStep] = useState('competing')
  const [activeIndex, setActiveIndex] = useState(0)

  const panes = useMemo(() => {
    const panes = [
      {
        menuItem: 'Event Registration',
        key: 'competing',
        render: () => (
          <Tab.Pane>
            <CompetingStep
              nextStep={() => {
                setActiveIndex(1)
              }}
            />
          </Tab.Pane>
        ),
      },
    ]
    if (competitionInfo['using_stripe_payments?']) {
      panes.push({
        menuItem: 'Payment',
        key: 'payment',
        render: () => (
          <Tab.Pane>
            <StripeWrapper />
          </Tab.Pane>
        ),
      })
    }
    return panes
  }, [competitionInfo])
  return (
    <div>
      <Tab renderActiveOnly panes={panes} activeIndex={activeIndex} />
    </div>
  )
}
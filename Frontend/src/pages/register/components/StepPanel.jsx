import React, { useContext, useEffect, useMemo, useState } from 'react'
import { Step } from 'semantic-ui-react'
import { CompetitionContext } from '../../../api/helper/context/competition_context'
import { RegistrationContext } from '../../../api/helper/context/registration_context'
import CompetingStep from './CompetingStep'
import RegistrationRequirements from './RegistrationRequirements'
import StripeWrapper from './StripeWrapper'

export default function StepPanel() {
  const { competitionInfo } = useContext(CompetitionContext)
  const { isRegistered } = useContext(RegistrationContext)
  const [activeIndex, setActiveIndex] = useState(0)

  const steps = useMemo(() => {
    const steps = [
      {
        key: 'requirements',
        label: 'Requirements',
        component: RegistrationRequirements,
      },
      {
        key: 'competing',
        label: 'Register',
        component: CompetingStep,
      },
    ]

    if (competitionInfo['using_stripe_payments?']) {
      steps.push({
        key: 'payment',
        label: 'Payment',
        component: StripeWrapper,
      })
    }
    return steps
  }, [competitionInfo])

  useEffect(() => {
    if (isRegistered) {
      setActiveIndex(1)
    }
  }, [isRegistered])

  const CurrentStepPanel = steps[activeIndex].component

  return (
    <>
      <Step.Group fluid ordered stackable="tablet">
        {steps.map((stepConfig, index) => (
          <Step
            key={stepConfig.key}
            active={activeIndex === index}
            completed={activeIndex > index}
            disabled={activeIndex < index}
          >
            <Step.Content>
              <Step.Title>{stepConfig.label}</Step.Title>
            </Step.Content>
          </Step>
        ))}
      </Step.Group>
      <CurrentStepPanel
        nextStep={() => setActiveIndex((oldActiveIndex) => oldActiveIndex + 1)}
      />
    </>
  )
}

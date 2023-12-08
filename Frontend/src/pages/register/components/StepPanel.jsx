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

  const steps = useMemo(() => {
    const steps = [requirementsStepConfig, competingStepConfig]

    if (competitionInfo['using_stripe_payments?']) {
      steps.push(paymentStepConfig)
    }

    return steps
  }, [competitionInfo])

  const [activeIndex, setActiveIndex] = useState(() =>
    steps.findIndex(
      (step) =>
        step === (isRegistered ? competingStepConfig : requirementsStepConfig)
    )
  )

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

const requirementsStepConfig = {
  key: 'requirements',
  label: 'Requirements',
  component: RegistrationRequirements,
}
const competingStepConfig = {
  key: 'competing',
  label: 'Register',
  component: CompetingStep,
}
const paymentStepConfig = {
  key: 'payment',
  label: 'Payment',
  component: StripeWrapper,
}

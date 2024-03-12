import React, { useContext, useMemo, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { Step } from 'semantic-ui-react'
import { CompetitionContext } from '../../../api/helper/context/competition_context'
import { RegistrationContext } from '../../../api/helper/context/registration_context'
import i18n from '../../../i18n'
import CompetingStep from './CompetingStep'
import RegistrationRequirements from './RegistrationRequirements'
import StripeWrapper from './StripeWrapper'

export default function StepPanel() {
  const { competitionInfo } = useContext(CompetitionContext)
  const { isRegistered } = useContext(RegistrationContext)

  const { t } = useTranslation(undefined, { i18n })

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
        step === (isRegistered ? competingStepConfig : requirementsStepConfig),
    ),
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
              <Step.Title>{t(stepConfig.i18nKey)}</Step.Title>
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
  i18nKey: 'competitions.registration_v2.requirements.title',
  component: RegistrationRequirements,
}
const competingStepConfig = {
  key: 'competing',
  i18nKey: 'competitions.nav.menu.register',
  component: CompetingStep,
}
const paymentStepConfig = {
  key: 'payment',
  i18nKey: 'competitions.registration_v2.tabs.payment',
  component: StripeWrapper,
}

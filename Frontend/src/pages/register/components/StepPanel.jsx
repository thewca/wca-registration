import React, { useContext, useMemo, useState } from 'react'
import {Icon, Step} from 'semantic-ui-react'
import { CompetitionContext } from '../../../api/helper/context/competition_context'
import CompetingStep from './CompetingStep'
import StripeWrapper from './StripeWrapper'

export default function StepPanel() {
  const { competitionInfo } = useContext(CompetitionContext)
  const [activeIndex, setActiveIndex] = useState(0)

  const panes = useMemo(() => {
    const panes = [
      {
        key: 'competing',
        label: 'Register',
        component: CompetingStep,
      },
    ]

    if (competitionInfo["using_stripe_payments?"]) {
      panes.push({
        key: 'payment',
        label: 'Payment',
        component: StripeWrapper,
      })
    }
    return panes
  }, [competitionInfo]);

  const CurrentStepPanel = panes[activeIndex].component;

  return (
      <>
          <Step.Group fluid ordered stackable="tablet">
              {panes.map((stepConfig, index) => (
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
  );
}

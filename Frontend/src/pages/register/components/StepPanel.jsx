import { UiIcon } from '@thewca/wca-components'
import React, { useContext, useMemo, useState } from 'react'
import { Menu, Tab } from 'semantic-ui-react'
import { CompetitionContext } from '../../../api/helper/context/competition_context'
import CompetingStep from './CompetingStep'
import StripeWrapper from './StripeWrapper'

export default function StepPanel() {
  const { competitionInfo } = useContext(CompetitionContext)
  const [activeIndex, setActiveIndex] = useState(0)

  const panes = useMemo(() => {
    const panes = [
      {
        menuItem: (
          <Menu.Item key="step-registration" onClick={() => setActiveIndex(0)}>
            <UiIcon name="sign in alt" />
            Register
          </Menu.Item>
        ),
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
        menuItem: (
          <Menu.Item key="step-payment" onClick={() => setActiveIndex(1)}>
            <UiIcon name="payment stripe" />
            Payment
          </Menu.Item>
        ),
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

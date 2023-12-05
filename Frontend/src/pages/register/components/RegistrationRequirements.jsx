import { UiIcon } from '@thewca/wca-components'
import { marked } from 'marked'
import React, {useContext, useEffect, useMemo, useState} from 'react'
import {Accordion, Button, Form, Message, Popup, Segment, Transition} from 'semantic-ui-react'
import { CompetitionContext } from '../../../api/helper/context/competition_context'

export default function RegistrationRequirements({ nextStep }) {
  const { competitionInfo } = useContext(CompetitionContext)

  const [generalInfoAcknowledged, setGeneralInfoAcknowledged] = useState(false);
  const [regRequirementsAcknowledged, setRegRequirementsAcknowledged] = useState(false);

  const [showRegRequirements, setShowRegRequirements] = useState(false);

  const setFromCheckbox = (data, setState) => {
    const { checked } = data;
    setState(checked);
  }

  const handleAccordionClick = () => {
    setShowRegRequirements((oldShowRegRequirements) => !oldShowRegRequirements);
  }

  const buttonDisabled = useMemo(() => {
    return !generalInfoAcknowledged || (competitionInfo.extra_registration_requirements && !regRequirementsAcknowledged);
  }, [
    competitionInfo.extra_registration_requirements,
    generalInfoAcknowledged,
    regRequirementsAcknowledged,
  ]);

  useEffect(() => {
    if (generalInfoAcknowledged) {
      setShowRegRequirements(true);
    }
  }, [generalInfoAcknowledged, setShowRegRequirements]);

  return (
    <Segment basic>
      <Form onSubmit={nextStep}>
        <Form.Checkbox
          checked={generalInfoAcknowledged}
          onClick={(_, data) => setFromCheckbox(data, setGeneralInfoAcknowledged)}
          label="I have read and acknowledged all information under the 'Register' tab, including entry fees and refund policies"
          required
        />
        {competitionInfo.extra_registration_requirements && (
          <>
            <Accordion as={Form.Field} styled fluid>
              <Accordion.Title
                  active={showRegRequirements}
                  index={0}
                  onClick={handleAccordionClick}
              >
                <UiIcon name="dropdown" />
                Additional Registration Requirements
              </Accordion.Title>
              <Transition visible={showRegRequirements} duration={500}>
                <Accordion.Content active={showRegRequirements}>
                  <p
                      dangerouslySetInnerHTML={{
                        __html: marked(
                            competitionInfo.extra_registration_requirements
                        ),
                      }}
                  />
                  <Message positive>
                    <Form.Checkbox
                        checked={regRequirementsAcknowledged}
                        onClick={(_, data) => setFromCheckbox(data, setRegRequirementsAcknowledged)}
                        label="I have read and understood all information listed above"
                        required
                    />
                  </Message>
                </Accordion.Content>
              </Transition>
            </Accordion>
          </>
        )}
        <Button disabled={buttonDisabled} type="submit" positive>
          Continue to next step
        </Button>
      </Form>
    </Segment>
  )
}

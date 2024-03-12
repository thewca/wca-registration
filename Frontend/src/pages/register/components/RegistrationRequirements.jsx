import { UiIcon } from '@thewca/wca-components'
import { marked } from 'marked'
import React, { useContext, useEffect, useMemo, useState } from 'react'
import { useTranslation } from 'react-i18next'
import {
  Accordion,
  Button,
  Form,
  Message,
  Segment,
  Transition,
} from 'semantic-ui-react'
import { CompetitionContext } from '../../../api/helper/context/competition_context'
import i18n, { TRANSLATIONS_NAMESPACE } from '../../../i18n'

export default function RegistrationRequirements({ nextStep }) {
  const { competitionInfo } = useContext(CompetitionContext)

  const [generalInfoAcknowledged, setGeneralInfoAcknowledged] = useState(false)
  const [regRequirementsAcknowledged, setRegRequirementsAcknowledged] =
    useState(false)

  const [showRegRequirements, setShowRegRequirements] = useState(false)

  const { t } = useTranslation(TRANSLATIONS_NAMESPACE, { i18n })

  const setFromCheckbox = (data, setState) => {
    const { checked } = data
    setState(checked)
  }

  const handleAccordionClick = () => {
    setShowRegRequirements((oldShowRegRequirements) => !oldShowRegRequirements)
  }

  const buttonDisabled = useMemo(() => {
    return (
      !generalInfoAcknowledged ||
      (competitionInfo.extra_registration_requirements &&
        !regRequirementsAcknowledged)
    )
  }, [
    competitionInfo.extra_registration_requirements,
    generalInfoAcknowledged,
    regRequirementsAcknowledged,
  ])

  useEffect(() => {
    if (generalInfoAcknowledged) {
      setShowRegRequirements(true)
    }
  }, [generalInfoAcknowledged, setShowRegRequirements])

  return (
    <Segment basic>
      <Form onSubmit={nextStep}>
        <Form.Checkbox
          checked={generalInfoAcknowledged}
          onClick={(_, data) =>
            setFromCheckbox(data, setGeneralInfoAcknowledged)
          }
          label={t('competitions.registration_v2.requirements.acknowledgement')}
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
                {t(
                  'competitions.competition_form.labels.registration.extra_requirements',
                )}
              </Accordion.Title>
              <Transition
                visible={showRegRequirements}
                animation="scale"
                duration={500}
              >
                <Accordion.Content active={showRegRequirements}>
                  <p
                    dangerouslySetInnerHTML={{
                      __html: marked(
                        competitionInfo.extra_registration_requirements,
                      ),
                    }}
                  />
                  <Message positive>
                    <Form.Checkbox
                      checked={regRequirementsAcknowledged}
                      onClick={(_, data) =>
                        setFromCheckbox(data, setRegRequirementsAcknowledged)
                      }
                      label={t(
                        'competitions.registration_v2.requirements.acknowledgment_extra',
                      )}
                      required
                    />
                  </Message>
                </Accordion.Content>
              </Transition>
            </Accordion>
          </>
        )}
        <Button disabled={buttonDisabled} type="submit" positive>
          {t('competitions.registration_v2.requirements.next_step')}
        </Button>
      </Form>
    </Segment>
  )
}

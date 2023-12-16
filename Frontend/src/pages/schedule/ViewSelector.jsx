import React from 'react'
import { Checkbox, Form } from 'semantic-ui-react'

export default function ViewSelector({ activeView, setActiveView }) {
  return (
    <Form>
      <Form.Field>
        <Checkbox
          radio
          label="Calendar View"
          name="viewGroup"
          value="calendar"
          checked={activeView === 'calendar'}
          onChange={(_, data) => setActiveView(data.value)}
        />
      </Form.Field>
      <Form.Field>
        <Checkbox
          radio
          label="Table View"
          name="viewGroup"
          value="table"
          checked={activeView === 'table'}
          onChange={(_, data) => setActiveView(data.value)}
        />
      </Form.Field>
    </Form>
  )
}

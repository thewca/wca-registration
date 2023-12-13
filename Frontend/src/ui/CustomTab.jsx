import { marked } from 'marked'
import React, { useContext } from 'react'
import { useParams } from 'react-router-dom'
import { Segment } from 'semantic-ui-react'
import { CompetitionContext } from '../api/helper/context/competition_context'

export default function CustomTab() {
  const { tab_id } = useParams()
  const { competitionInfo } = useContext(CompetitionContext)
  const tab = competitionInfo.tabs.find((tab) => tab.id.toString() === tab_id)
  return (
    <Segment padded attached>
      <span dangerouslySetInnerHTML={{ __html: marked(tab.content) }} />
    </Segment>
  )
}

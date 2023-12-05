import { marked } from 'marked'
import React, { useContext } from 'react'
import { Segment } from 'semantic-ui-react'
import { CompetitionContext } from '../../api/helper/context/competition_context'

export default function HomePage() {
  const { competitionInfo } = useContext(CompetitionContext)
  return (
    <Segment attached padded>
      {competitionInfo.information && (
        <div
          dangerouslySetInnerHTML={{
            __html: marked(competitionInfo.information),
          }}
        />
      )}
    </Segment>
  )
}

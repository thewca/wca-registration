import { useQuery } from '@tanstack/react-query'
import React, { useContext } from 'react'
import getSchedule from '../../api/competition/get/get_schedule'
import { CompetitionContext } from '../../api/helper/context/competition_context'
import { setMessage } from '../../ui/events/messages'
import LoadingMessage from '../../ui/messages/loadingMessage'
import styles from './index.modules.scss'

export default function Schedule() {
  const { competitionInfo } = useContext(CompetitionContext)
  const { isLoading, data: schedule } = useQuery({
    queryKey: ['schedule', competitionInfo.id],
    queryFn: () => getSchedule(competitionInfo.id),
    retry: false,
    onError: (err) => {
      setMessage(err.message, 'error')
    },
  })
  return isLoading ? (
    <LoadingMessage />
  ) : (
    <div style={styles.scheduleWrapper}>
      <table className="show-events-table">
        <thead>
          <tr>
            <th>Event</th>
            <th>Round</th>
            <th>Format</th>
            <th>Time Limit</th>
            {competitionInfo['uses_cutoff?'] && <th>cutoff</th>}
            <th>Proceed</th>
            {competitionInfo['uses_qualification?'] && <th>qualifcation</th>}
          </tr>
        </thead>

        {/*<tbody>*/}
        {/*<*/}
        {/*% @competition.competition_events.sort_by {|ce| ce.event.rank}.each do |competition_event| %>*/}
        {/*<% competition_event.rounds.each do |round| %>*/}
        {/*<tr className="<%= round.final_round? ? " last-round" : "" %>">*/}
        {/*  <td>*/}
        {/*    <*/}
        {/*    %= competition_event.event.name if round.number == 1 %>*/}
        {/*  </td>*/}
        {/*  <td>*/}
        {/*    <*/}
        {/*    %= round.round_type.name %>*/}
        {/*  </td>*/}
        {/*  <td>*/}
        {/*    <*/}
        {/*    %= round.full_format_name(with_short_names: true, with_tooltips: true) %>*/}
        {/*  </td>*/}
        {/*  <td>*/}
        {/*    <*/}
        {/*    %= round.time_limit_to_s %>*/}
        {/*    <% if competition_event.event.can_change_time_limit? %>*/}
        {/*    <% if round.time_limit.cumulative_round_ids.length == 1 %>*/}
        {/*    <%= link_to "*", "#cumulative-time-limit" %>*/}
        {/*    <% elsif round.time_limit.cumulative_round_ids.length > 1 %>*/}
        {/*    <%= link_to "**", "#cumulative-across-rounds-time-limit" %>*/}
        {/*    <% end %>*/}
        {/*    <% end %>*/}
        {/*  </td>*/}
        {/*  <*/}
        {/*  % if @competition.uses_cutoff? %>*/}
        {/*  <td>*/}
        {/*    <*/}
        {/*    %= round.cutoff_to_s %></td>*/}
        {/*  <*/}
        {/*  % end %>*/}
        {/*  <td>*/}
        {/*    <*/}
        {/*    %= round.advancement_condition_to_s %></td>*/}
        {/*  <*/}
        {/*  % if @competition.uses_qualification? %>*/}
        {/*  <% if round.number == 1 %>*/}
        {/*  <td>*/}
        {/*    <*/}
        {/*    %= competition_event.qualification_to_s %></td>*/}
        {/*  <*/}
        {/*  % else %>*/}
        {/*  <td></td>*/}
        {/*  <*/}
        {/*  % end %>*/}
        {/*  <% end %>*/}
        {/*</tr>*/}
        {/*<*/}
        {/*% end %>*/}
        {/*<% end %>*/}
        {/*</tbody>*/}
      </table>
    </div>
  )
}

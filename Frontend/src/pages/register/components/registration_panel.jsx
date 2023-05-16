import React, {useState} from 'react';
import styles from "./panel.module.scss"
import submit_event_registration from "../../../api/registration/post/submit_registration";

const EVENTS = [ "3x3", "4x4" ]

function toggleElementFromArray(arr, element) {
    const index = arr.indexOf(element);
    index !== -1 ? arr.splice(index, 1) : arr.push(element);
    return arr;
}


function EventSelection({ events, setEvents }){
    return <div className={styles.events}>
    {
        EVENTS.map( (wca_event) => <label>
            {wca_event}<input type="checkbox" value="0" name={`event-${wca_event}`}
        onChange={ e => setEvents(toggleElementFromArray(events, wca_event))}/>
        </label>)
    }
    </div>
}


export default function RegistrationPanel({ }) {
    const [competitorID, setCompetitorID] = useState('2012ICKL01');
    const [competitionID, setCompetitionID] = useState('HessenOpen2023');
    const [events, setEvents] = useState([])

    return <div className={styles.panel}>
        <label>
            Competitor_id
            <input type="text" value={competitorID} name="competitor_id"
                   onChange={ e => setCompetitorID(e.target.value)} />
        </label>
        <label>
            Competition_id
            <input type="text" value={competitionID} name="competition_id"
                   onChange={ e => setCompetitionID(e.target.value)}/>
        </label>
        <EventSelection events={events} setEvents={setEvents}> </EventSelection>
        <button onClick={_ => submit_event_registration(competitorID, competitionID, events)}> Insert Registration</button>
    </div>
}
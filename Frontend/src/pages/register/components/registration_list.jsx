import React, {useState} from 'react';
import styles from "./list.module.scss"
import getRegistrations from "../../../api/registration/get/get_registrations";
import deleteRegistration from "../../../api/registration/delete/delete_registration";
import updateRegistration from "../../../api/registration/patch/update_registration";

function StatusDropdown({ status, setStatus }) {
    const options = ["waiting", "accepted"]
    return <select onChange={ e => setStatus(e.target.value)} value={status}>
        {options.map( (opt) => <option selected={ status === opt }>
            {opt}
        </option>)}
    </select>;
}

function RegistrationRow( { competitorId, eventIDs, serverStatus, competitionID, setRegistrationList }) {
    const [status, setStatus] = useState(serverStatus)

    return <tr>
        <td>{competitorId}</td>
        <td>{eventIDs.join(",")}</td>
        <td><StatusDropdown status={status} setStatus={setStatus}></StatusDropdown></td>
        <td><button onClick={ _=> {
            updateRegistration(competitorId, competitionID, status)
        }
        }> Apply</button></td>
        <td><button onClick={ _ => {
            deleteRegistration(competitorId, competitionID);
            setRegistrationList(registrationList.filter((r) => r.competitor_id !== competitorId))
        }
        }> Delete</button></td>
    </tr>
}

async function getRegistrationFromServer(competitionID){
    const data = await getRegistrations(competitionID)
    if(data.error){
        console.log(data)
    }else{
        return data
    }
}

export default function RegistrationList({ }) {
    const [competitionID, setCompetitionID] = useState('HessenOpen2023');
    const [registrationList, setRegistrationList] = useState([])
    return <div className={styles.list}>
        <button onClick={async (_) => setRegistrationList(await getRegistrationFromServer(competitionID))}> List Registrations</button>
        <label>
            Competition_id
            <input type="text" value={competitionID} name="list_competition_id"
            onChange={ e => setCompetitionID(e.target.value)}/>
        </label>
        <table>
            <thead>
            <tr>
                <th> Competitor</th>
                <th> Events </th>
                <th> Status </th>
                <th> Apply Changes </th>
                <th> Delete </th>
            </tr>
            </thead>
            <tbody>
            {
                registrationList.map(registration => {
                    return <RegistrationRow competitorId={registration.competitor_id}
                                            setRegistrationList={setRegistrationList}
                                            eventIDs={registration.event_ids}
                                            competitionID={competitionID}
                                            serverStatus={registration.registration_status}
                                            registrationList={registrationList}></RegistrationRow>
                })
            }
            </tbody>
        </table>
    </div>
}

import backendFetch from "../../helper/backend_fetch";

export default async function deleteRegistration(competitorID, competitionID){
    const formData = new FormData();
    formData.append('competitor_id', competitorID);
    formData.append('competition_id', competitionID);

    return await backendFetch("/register", "DELETE", formData);
}

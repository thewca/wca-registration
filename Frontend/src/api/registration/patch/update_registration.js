import backendFetch from "../../helper/backend_fetch";

export default async function updateRegistration(competitorID, competitionID, status){
    const formData = new FormData();
    formData.append('competitor_id', competitorID);
    formData.append('competition_id', competitionID);
    formData.append("status", status);

    return await backendFetch("/register", "PATCH", formData);
}

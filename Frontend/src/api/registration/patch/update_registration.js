export default async function update_registration(competitorID, competitionID, status){
    const formData = new FormData();
    formData.append('competitor_id', competitorID);
    formData.append('competition_id', competitionID);
    formData.append("status", status)
    try {
        const response = await fetch('http://localhost:3001/register', {
            method: 'PATCH',
            body: formData
        });

        if (response.ok) {
            return await response.json()
        } else {
            return {error: response.statusText, statusCode: response.status}
        }
    } catch (error) {
        return {error: error, statusCode: 500}
    }
}
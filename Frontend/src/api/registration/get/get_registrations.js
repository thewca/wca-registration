export default async function getRegistrations(competitionID){
    try {
        const response = await fetch(`http://localhost:3001/registrations?competition_id=${competitionID}`);
        if (response.ok) {
            return await response.json()
        } else {
            return {error: response.statusText, statusCode: response.status}
        }
    } catch (error) {
        return {error: error, statusCode: 500}
    }
}
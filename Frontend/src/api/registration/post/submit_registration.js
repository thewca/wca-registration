export default async function submit_event_registration(competitorId, competitionId, events){
    console.log(competitionId, competitorId,events)
    const formData = new FormData();
    formData.append('competitor_id', competitorId);
    formData.append('competition_id', competitionId);
    events.forEach(eventId => formData.append('event_ids[]', eventId));
    try {
        const response = await fetch('http://localhost:3001/register', {
            method: 'POST',
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
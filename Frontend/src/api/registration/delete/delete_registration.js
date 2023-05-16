export default async function delete_registration(competitor_id, competition_id){
    const formData = new FormData();
    formData.append('competitor_id', competitor_id);
    formData.append('competition_id', competition_id);

    try {
        const response = await fetch('http://localhost:3001/register', {
            method: 'DELETE',
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
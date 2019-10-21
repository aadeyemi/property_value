export function testApi() {
    const api =
        "http://127.0.0.1:8000/api/v0/search/addr/tx_harris/14736%20branchwest%20dr/";

    function headers(type, payload) {
        const obj = {
            method: type,
            headers: {
                Accept: "application/json",
                Authorization: `Token ${""}`,
                "Content-Type": "application/json"
            }
        };

        if (type === "POST") obj.body = JSON.stringify(payload);

        return obj;
    }

    function handleErrors(response) {
        if (!response.ok) {
            throw Error(`Request rejected with status ${response.statusText}`);
        }
        return response;
    }

    function callback(data) {
        return console.log(data);
    }

    fetch(api, headers("GET", {}))
        .then(response => handleErrors(response))
        .then(response => response.json())
        .then(responseJson => callback(responseJson))
        .catch(error => console.log(api, error));
}
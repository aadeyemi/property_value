import React from "react";

function testApi() {
  const api = "http://127.0.0.1:8000/api/v0/real-acct/texas/harris/1000/";

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

function App() {
  testApi();
  return <div className = "App" / > ;
}

export default App;
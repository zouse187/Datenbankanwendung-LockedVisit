fetch("http://localhost:3000/api/besucher")
      .then(r => r.json())
      .then(data => {
        document.getElementById("output").textContent =
          JSON.stringify(data, null, 2);
      })
      .catch(err => {
        document.getElementById("output").textContent = "Fehler: " + err;
      });
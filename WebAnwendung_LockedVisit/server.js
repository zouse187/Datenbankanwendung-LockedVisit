const express = require("express");
const oracledb = require("oracledb");

const app = express();
const PORT = 3000;

app.use(express.static(__dirname));

// Optional: JSON pretty
app.set("json spaces", 2);

async function runQuery(sql, binds = []) {
  let conn;
  try {
    conn = await oracledb.getConnection({
      user: "mborghardt",
      password: "M15d26m26!",
      connectString: "rs03-db-inf-min.ad.fh-bielefeld.de:1521/orcl.rs03-db-inf-min.ad.fh-bielefeld.de"
    });

    const result = await conn.execute(sql, binds, { outFormat: oracledb.OUT_FORMAT_OBJECT });
    return result.rows;
  } finally {
    if (conn) {
      await conn.close();
    }
  }
}

// Beispiel‑Endpoint: alle Besucher
app.get("/api/besucher", async (req, res) => {
  try {
    const rows = await runQuery("SELECT * FROM BESUCHER");
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "DB error" });
  }
});

app.listen(PORT, () => {
  console.log(`Server läuft auf http://localhost:${PORT}/index.html`);
});

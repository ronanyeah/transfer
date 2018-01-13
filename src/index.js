const lf = require("localforage");

const db1 = lf.createInstance({
  name: "db-1"
});

const db2 = lf.createInstance({
  name: "db-2"
});

db1.setItem("1515723149524", { name: "rupert", age: 25 });
db1.setItem("1515723350280", { name: "david", age: 12 });
db1.setItem("1515723358727", { name: "donnie", age: 42 });

db2.setItem("1515723158555", { name: "maisie", age: 32 });
db2.setItem("1515723383304", { name: "sarah", age: 91 });
db2.setItem("1515723406866", { name: "laura", age: 14 });

const Elm = require("./Main.elm");

(async () => {
  const data1 = await db1
    .keys()
    .then(keys =>
      Promise.all(
        keys.map(k => db1.getItem(k).then(v => Object.assign(v, { id: k })))
      )
    );

  const data2 = await db2
    .keys()
    .then(keys =>
      Promise.all(
        keys.map(k => db2.getItem(k).then(v => Object.assign(v, { id: k })))
      )
    );

  const app = Elm.Main.fullscreen();

  app.ports.db1Data.send(data1);

  app.ports.db2Data.send(data2);

  app.ports.moveToDb1.subscribe(console.log);

  app.ports.moveToDb2.subscribe(console.log);
})().catch(console.error);

const lf = require("localforage");

const db1 = lf.createInstance({
  name: "db-1"
});

const db2 = lf.createInstance({
  name: "db-2"
});

const Elm = require("./Main.elm");

const getDb1 = () =>
  db1
    .keys()
    .then(keys =>
      Promise.all(
        keys.map(k => db1.getItem(k).then(v => Object.assign(v, { id: k })))
      )
    );

const getDb2 = () =>
  db2
    .keys()
    .then(keys =>
      Promise.all(
        keys.map(k => db2.getItem(k).then(v => Object.assign(v, { id: k })))
      )
    );

(async () => {
  await db1.clear();
  await db2.clear();

  await db1.setItem("1515723149524", { name: "rupert", age: 25 });
  await db1.setItem("1515723350280", { name: "david", age: 12 });
  await db1.setItem("1515723358727", { name: "donnie", age: 42 });

  await db2.setItem("1515723158555", { name: "maisie", age: 32 });
  await db2.setItem("1515723383304", { name: "sarah", age: 91 });
  await db2.setItem("1515723406866", { name: "laura", age: 14 });

  const app = Elm.Main.fullscreen();

  app.ports.db1Data.send(await getDb1());
  app.ports.db2Data.send(await getDb2());

  app.ports.moveToDb1.subscribe(async id => {
    const person = await db2.getItem(id);

    if (!person) return;

    await db2.removeItem(id);

    await db1.setItem(id, person);

    app.ports.db1Data.send(await getDb1());
    app.ports.db2Data.send(await getDb2());
  });

  app.ports.moveToDb2.subscribe(async id => {
    const person = await db1.getItem(id);

    if (!person) return;

    await db1.removeItem(id);

    await db2.setItem(id, person);

    app.ports.db1Data.send(await getDb1());
    app.ports.db2Data.send(await getDb2());
  });
})().catch(console.error);

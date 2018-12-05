const port = process.env.PORT || 3000;
const express = require('express');

const app = express();

app.get('/', (req, res) => {
  res.send('Hi there');
});

app.listen(port, () => {
  console.log(`listening on port${port}`);
})
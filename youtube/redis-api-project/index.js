require('dotenv').config();
const express = require('express');
const axios = require('axios');
const cors = require('cors');
const Redis = require('redis');
const bodyParser = require('body-parser');

const DEFAULT_EXPIRATION = 3600; // 1 hour = 3600 seconds

// instance of redis
const redisClient = Redis.createClient({
  legacyMode: true,
  disableOfflineQueue: true,
  socket: {
    port: 6379,
    reconnectStrategy: () => 3000,
  },
}); // pass arg "url" if production
(async () => {
  await redisClient.connect();
})();

const app = express();
app.use(express.urlencoded({ extended: true }));
app.use(bodyParser.json());
app.use(cors());

app.get('/photos', async (req, res) => {
  const albumId = req.query.albumId;
  const photos = await getOrSetCache(`photos?albumId=${albumId}`, async () => {
    const { data } = await axios.get(
      'https://jsonplaceholder.typicode.com/photos',
      { params: { albumId } }
    );
    return data;
  });

  res.json(photos);
});

app.get('/photos/:id', async (req, res) => {
  const photo = await getOrSetCache(`photos:${req.params.id}`, async () => {
    const { data } = await axios.get(
      `https://jsonplaceholder.typicode.com/photos/${req.params.id}`
    );
    return data;
  });

  res.json(photo);
});

function getOrSetCache(key, cb) {
  return new Promise((resolve, reject) => {
    redisClient.get(key, async (error, data) => {
      if (error) return reject(error);
      if (data != null) return resolve(JSON.parse(data));

      const freshData = await cb();
      redisClient.set(key, JSON.stringify(freshData), 'EX', DEFAULT_EXPIRATION);
      resolve(freshData);
    });
  });
}

app.listen(3000, () => {
  console.log('Server is listening on port 3000!');
});

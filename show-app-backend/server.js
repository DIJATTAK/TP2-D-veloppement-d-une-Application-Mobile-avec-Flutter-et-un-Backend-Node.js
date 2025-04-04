require('dotenv').config();
const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const jwt = require('jsonwebtoken');
const showRoutes = require('./routes/shows');

const app = express();
const PORT = process.env.PORT || 5000;

app.use(cors());
app.use(bodyParser.json());
app.use('/uploads', express.static('uploads'));
app.use('/shows', showRoutes);

const users = [
  {
    id: 1,
    email: 'attak@example.com',
    password: 'password123', // En production, n'utilisez jamais de mots de passe en clair
  },
];

const secretKey = 'your-secret-key';

// Endpoint de connexion
app.post('/login', (req, res) => {
  const { email, password } = req.body;

  const user = users.find(u => u.email === email && u.password === password);

  if (user) {
    const token = jwt.sign({ id: user.id, email: user.email }, secretKey, { expiresIn: '1h' });
    res.json({ token });
  } else {
    res.status(401).json({ message: 'Invalid email or password' });
  }
});

app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:5000`);
});
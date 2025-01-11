const express = require('express');
const bodyParser = require('body-parser');
const passport = require('passport');
const session = require('express-session');
require('dotenv').config();

const app = express();
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(session({ secret: 'aenzbi-suite', resave: false, saveUninitialized: true }));
app.use(passport.initialize());
app.use(passport.session());

// Authentication strategies (placeholder for Google, Facebook, etc.)
require('./strategies/google')(passport);
require('./strategies/facebook')(passport);
require('./strategies/github')(passport);
require('./strategies/microsoft')(passport);
require('./strategies/local')(passport);

// Default route
app.get('/', (req, res) => {
  res.send('Welcome to Aenzbi Suite Authentication!');
});

// Start the app
const PORT = process.env.PORT || 8080;
app.listen(PORT, () => console.log(`App running on port ${PORT}`));

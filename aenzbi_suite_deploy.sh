#!/bin/bash

# Define variables
PROJECT_ID="aenzbi-suite" # Replace with your Google Cloud project ID
REGION="us-central1"
SERVICE_NAME="aenzbi-suite"
REPO_NAME="aenzbi-suite"
APP_PORT=8080

# Step 1: Create Google Cloud Project
gcloud projects create $PROJECT_ID --name="Aenzbi Suite" || echo "Project already exists."

# Set the project in gcloud
gcloud config set project $PROJECT_ID

# Enable necessary APIs
gcloud services enable run.googleapis.com
gcloud services enable firebase.googleapis.com
gcloud services enable cloudbuild.googleapis.com

# Step 2: Clone or initialize the app
if [ ! -d $REPO_NAME ]; then
  mkdir $REPO_NAME && cd $REPO_NAME
  npm init -y
else
  echo "Repository already exists. Skipping initialization."
  cd $REPO_NAME
fi

# Install necessary dependencies
npm install express passport passport-google-oauth passport-facebook passport-github passport-microsoft passport-local body-parser dotenv

# Step 3: Create a basic Node.js app
cat <<EOF > index.js
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
const PORT = process.env.PORT || $APP_PORT;
app.listen(PORT, () => console.log(\`App running on port \${PORT}\`));
EOF

# Step 4: Add Passport strategies (Google example)
mkdir strategies
cat <<EOF > strategies/google.js
const GoogleStrategy = require('passport-google-oauth').OAuth2Strategy;

module.exports = (passport) => {
  passport.use(new GoogleStrategy({
    clientID: process.env.GOOGLE_CLIENT_ID,
    clientSecret: process.env.GOOGLE_CLIENT_SECRET,
    callbackURL: "/auth/google/callback"
  }, (accessToken, refreshToken, profile, done) => {
    return done(null, profile);
  }));
};
EOF

# Add similar files for Facebook, GitHub, Microsoft, and local strategies.

# Step 5: Create Dockerfile
cat <<EOF > Dockerfile
# Use Node.js LTS image
FROM node:lts

# Set working directory
WORKDIR /usr/src/app

# Copy app files
COPY package*.json ./
COPY . .

# Install dependencies
RUN npm install

# Expose the app port
EXPOSE $APP_PORT

# Start the app
CMD ["node", "index.js"]
EOF

# Step 6: Deploy to Google Cloud Run
gcloud builds submit --tag gcr.io/$PROJECT_ID/$SERVICE_NAME
gcloud run deploy $SERVICE_NAME \
  --image gcr.io/$PROJECT_ID/$SERVICE_NAME \
  --platform managed \
  --region $REGION \
  --allow-unauthenticated \
  --port $APP_PORT

# Step 7: Output service URL
SERVICE_URL=$(gcloud run services describe $SERVICE_NAME --region $REGION --format='value(status.url)')
echo "Aenzbi Suite deployed successfully! Visit: $SERVICE_URL"
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
EXPOSE 8080

# Start the app
CMD ["node", "index.js"]

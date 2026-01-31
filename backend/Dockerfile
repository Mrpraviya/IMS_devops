 FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm ci --only=production

# Install curl for testing inside container
RUN apk add --no-cache curl

# Copy the rest of the application
COPY . .

# Copy environment variables
COPY .env .env

# Start the backend
CMD ["node", "index.js"]



# backend/Dockerfile
FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install only production dependencies
RUN npm ci --only=production

# Copy source code
COPY . .

# Copy .env (optional: could also pass via docker-compose)
COPY .env .env

# Expose backend port
EXPOSE 5000

# Start server
CMD ["node", "index.js"]

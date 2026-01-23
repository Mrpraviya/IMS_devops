# FROM node:18
# WORKDIR /app
# COPY package*.json ./
# RUN npm install
# COPY . .
# EXPOSE 5000
# CMD ["npm", "run", "dev"]

FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install ALL dependencies (including dev dependencies like nodemon)
RUN npm install

# Copy source code
COPY . .

# Expose port
EXPOSE 5000

# Start command
CMD ["npm", "run", "dev"]
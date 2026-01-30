 FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install ALL dependencies (including dev dependencies like nodemon)
# RUN npm install
RUN npm ci --only=production

# Copy source code
COPY . .

# Copy .env file
COPY .env .env


# Expose port
EXPOSE 5000

COPY wait-for-mongo.sh /wait-for-mongo.sh
RUN chmod +x /wait-for-mongo.sh

# Start command
CMD ["/wait-for-mongo.sh", "ims-mongodb", "npm", "run", "start"]

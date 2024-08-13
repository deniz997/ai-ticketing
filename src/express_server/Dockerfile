# Use Node.js official image as a parent image
FROM node:18

# Set the working directory
WORKDIR /usr/src/app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN #npm install
RUN npm ci && npm cache clean --force

# Copy the rest of the application code
COPY . .

# Expose the port the app runs on
EXPOSE ${EXPRESS_SERVER_PORT}

# Run the application
CMD ["node", "index.js"]

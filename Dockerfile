# specify a base image
FROM node:8

WORKDIR /usr/app

# install some dependencies
COPY ./package.json ./
RUN npm install
COPY . .

# Expose port from container so host can access 3000
EXPOSE 8080

# defult command
CMD ["npm", "start"]
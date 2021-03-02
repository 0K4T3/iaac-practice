FROM node:14.16.0-alpine
WORKDIR /opt/web
ENV PATH /opt/web/node_modules/.bin:$PATH

EXPOSE 3000
CMD ["sh", "-c", "npm install && REACT_APP_API_ENDPOINT=${API_ENDPOINT} npm run start"]

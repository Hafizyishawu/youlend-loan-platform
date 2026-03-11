# Stage 1: Build Angular application
FROM node:20-alpine AS build

WORKDIR /app

# Copy package files
COPY package*.json ./
RUN npm ci

# Copy source code
COPY . .

# Upgrade zlib to ensure we have the patched version
RUN apk update && apk upgrade zlib

# Build arguments for environment configuration
ARG API_URL
ARG AUTH0_DOMAIN
ARG AUTH0_CLIENT_ID
ARG REDIRECT_URI

# Create both environment.ts and environment.prod.ts from template
RUN cp src/environments/environment.template.ts src/environments/environment.ts && \
    cp src/environments/environment.template.ts src/environments/environment.prod.ts && \
    sed -i "s|\${API_URL}|${API_URL}|g" src/environments/environment.ts && \
    sed -i "s|\${AUTH0_DOMAIN}|${AUTH0_DOMAIN}|g" src/environments/environment.ts && \
    sed -i "s|\${AUTH0_CLIENT_ID}|${AUTH0_CLIENT_ID}|g" src/environments/environment.ts && \
    sed -i "s|\${REDIRECT_URI}|${REDIRECT_URI}|g" src/environments/environment.ts && \
    sed -i "s|\${API_URL}|${API_URL}|g" src/environments/environment.prod.ts && \
    sed -i "s|\${AUTH0_DOMAIN}|${AUTH0_DOMAIN}|g" src/environments/environment.prod.ts && \
    sed -i "s|\${AUTH0_CLIENT_ID}|${AUTH0_CLIENT_ID}|g" src/environments/environment.prod.ts && \
    sed -i "s|\${REDIRECT_URI}|${REDIRECT_URI}|g" src/environments/environment.prod.ts

# Build application for production
RUN npm run build -- --configuration production

# Stage 2: Serve with Nginx
FROM nginx:stable-alpine

# Upgrade zlib to patched version
RUN apk update && apk upgrade zlib

# Copy custom nginx config
COPY nginx.conf /etc/nginx/nginx.conf

# Copy built application from build stage
COPY --from=build /app/dist/youlend-loan-frontend/browser /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost/ || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
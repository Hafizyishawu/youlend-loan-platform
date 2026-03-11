# Stage 1: Build Angular application
FROM node:20-alpine AS build

WORKDIR /app

# Copy package files
COPY package*.json ./
RUN npm ci

# Copy source code
COPY . .

# Build arguments - values come from GitHub Secrets at runtime
ARG API_URL
ARG AUTH0_DOMAIN
ARG AUTH0_CLIENT_ID
ARG REDIRECT_URI

# Generate production environment file from build args
RUN cat > src/environments/environment.prod.templatets << EOF
export const environment = {
  production: true,
  demoMode: false,
  apiUrl: '${API_URL}',
  auth0: {
    domain: '${AUTH0_DOMAIN}',
    clientId: '${AUTH0_CLIENT_ID}',
    authorizationParams: {
      redirect_uri: '${REDIRECT_URI}'
    }
  }
};
EOF

# Build application
RUN npm run build -- --configuration production

# Stage 2: Nginx
FROM nginx:alpine
COPY nginx.conf /etc/nginx/nginx.conf
COPY --from=build /app/dist/youlend-loan-frontend/browser /usr/share/nginx/html
EXPOSE 80
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost/ || exit 1
CMD ["nginx", "-g", "daemon off;"]
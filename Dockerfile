# Stage 1: Build Flutter Web App using official Flutter image
FROM ghcr.io/cirruslabs/flutter:stable AS build-env

# Switch to root for dependency installation
USER root

WORKDIR /app

# Copy Flutter project files
COPY gymbuddy_app/ /app/

# Get dependencies and build for web
RUN flutter pub get && \
    flutter build web --release \
        --dart-define=GEMINI_API_KEY=${GEMINI_API_KEY} \
        --dart-define=TWILIO_ACCOUNT_SID=${TWILIO_ACCOUNT_SID} \
        --dart-define=TWILIO_AUTH_TOKEN=${TWILIO_AUTH_TOKEN} \
        --dart-define=TWILIO_WHATSAPP_FROM=${TWILIO_WHATSAPP_FROM} \
        --dart-define=TWILIO_CONTENT_SID=${TWILIO_CONTENT_SID}

# Stage 2: Serve with lightweight Nginx
FROM nginx:alpine

COPY --from=build-env /app/build/web /usr/share/nginx/html

# Configure Nginx to listen on port 8080
RUN printf 'server {\n\
    listen 8080;\n\
    server_name localhost;\n\
    location / {\n\
        root /usr/share/nginx/html;\n\
        index index.html index.htm;\n\
        try_files $uri $uri/ /index.html;\n\
    }\n\
}\n' > /etc/nginx/conf.d/default.conf

EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]

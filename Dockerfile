# Stage 1: Build Flutter Web App
FROM debian:latest AS build-env

RUN apt-get update && apt-get install -y \
    curl git wget unzip libgconf-2-4 gdb libstdc++6 libglu1-mesa fonts-droid-fallback \
    && apt-get clean

# Clone Flutter SDK
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Enable Flutter Web & verify
RUN flutter channel stable && flutter upgrade && flutter config --enable-web

# Copy Flutter project
WORKDIR /app
COPY gymbuddy_app/ /app/

# Build Web release
RUN flutter pub get && flutter build web --release

# Stage 2: Serve with lightweight Nginx
FROM nginx:alpine
COPY --from=build-env /app/build/web /usr/share/nginx/html
COPY <<EOF /etc/nginx/conf.d/default.conf
server {
    listen 8080;
    server_name localhost;
    location / {
        root /usr/share/nginx/html;
        index index.html index.htm;
        try_files \$uri \$uri/ /index.html;
    }
}
EOF

EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]

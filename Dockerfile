FROM flutter:3.19.0 AS build

WORKDIR /app

COPY pubspec.yaml .
COPY pubspec.lock .

RUN flutter pub get

COPY . .

RUN flutter build web --release

FROM nginx:alpine AS serve
COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]

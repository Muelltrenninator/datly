FROM dart:stable AS build

WORKDIR /app
COPY . .
RUN sed -i "s/- packages\/datly_client/# - packages\/datly_client/" pubspec.yaml

WORKDIR /app/packages/datly_server
RUN dart pub get
RUN dart compile exe bin/server.dart -o bin/server

FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /app/packages/datly_server/bin/legal/ /app/bin/legal/
COPY --from=build /app/packages/datly_server/bin/public/ /app/bin/public/
COPY --from=build /app/packages/datly_server/bin/sqlite/ /app/bin/sqlite/
COPY --from=build /app/packages/datly_server/bin/server /app/bin/

COPY --from=pandoc/minimal:3 /usr/local/bin/pandoc /usr/local/bin/pandoc

EXPOSE 33552
CMD ["/app/bin/server"]

FROM golang:1.20-alpine AS build

WORKDIR /usr/src/app

COPY ./golangapp/go.mod ./
RUN go mod download && go mod verify

COPY ./golangapp .
RUN go build -v -o /usr/src/app/app ./...

FROM scratch

COPY --from=build /usr/src/app/app /app

ENTRYPOINT ["/app"]


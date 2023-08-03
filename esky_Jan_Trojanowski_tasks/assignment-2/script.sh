#!/bin/bash
# author: Jan Trojanowski

# Function to print usage message
function usage {
  echo "Usage: $0 [--port|-p <port_number>]"
  echo "Options:"
  echo "  --port|-p <port_number> With this parameter you can set the port for the application (default is 8080)"
  exit 1
}

deploy_app() {
  port="${1:-8080}"
  docker build -t my-golang-app .
  docker run -it --rm --name my-running-app -p "$port:8080" my-golang-app
}

case "$1" in
  --port|-p)
    shift
    deploy_app "$1"
    ;;
  --help|-h)
    usage
    ;;
  *)
    deploy_app
    ;;
esac


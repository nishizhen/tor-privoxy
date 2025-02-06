// Special target: https://github.com/docker/metadata-action#bake-definition
target "docker-metadata-action" {}

group "default" {
  targets = ["tor-privoxy"]
}

target "tor-privoxy" {
  inherits  = ["docker-metadata-action"]
  platforms  = [
    "linux/386",
    "linux/amd64"
  ]
}

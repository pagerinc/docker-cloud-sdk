#!/usr/bin/env bats

@test "It should install docker in PATH" {
  command -v docker
}

@test "It should use docker 18.09.x" {
  docker --version | grep 18.09
}

@test "It should install sops in PATH" {
  command -v sops
}

@test "It should use sops 3.3.x" {
  sops --version | grep 3.3
}

@test "It should install helm in PATH" {
  command -v helm
}

@test "It should use helm 2.16.x" {
  helm version | grep 2.16
}

@test "It should install helm diff plugin" {
  helm plugin list | grep -e diff
}

@test "It should install gcloud in PATH" {
  command -v gcloud
}

@test "It should use gcloud 272.0.x" {
  gcloud --version | grep 272.0
}

@test "It should install shellcheck in PATH" {
  command -v shellcheck
}

@test "It should use shellcheck 0.7.x" {
  shellcheck --version | grep 0.7
}

@test "It should install kubeval in PATH" {
  command -v kubeval
}

@test "It should use kubeval 0.14.x" {
  kubeval --version | grep 0.14
}

@test "It should install docker-compose in PATH" {
  command -v docker-compose
}

#!/usr/bin/env bats

@test "It should install docker in PATH" {
  which docker
}

@test "It should use docker 18.09.x" {
  docker --version | grep 18.09
}

@test "It should install sops in PATH" {
  which sops
}

@test "It should use sops 3.3.x" {
  sops --version | grep 3.3
}

@test "It should install helm in PATH" {
  which helm
}

@test "It should use helm 2.14.x" {
  helm version | grep 2.14
}

@test "It should install gcloud in PATH" {
  which gcloud
}

@test "It should use gcloud 260.0.x" {
  gcloud --version | grep 261.0
}

@test "It should install hub in PATH" {
  which hub
}

@test "It should use hub 2.12.x" {
  hub --version | grep 2.12
}

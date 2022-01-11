@echo off

DOSKEY podman=wsl sudo podman $*
DOSKEY docker=wsl sudo podman $*
DOSKEY docker-compose=wsl sudo docker-compose $*

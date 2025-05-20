#!/bin/sh

# Start socat in the background to forward port 8080 to 11434
socat TCP-LISTEN:8080,fork TCP:localhost:11434 &

# Start Ollama
exec serve

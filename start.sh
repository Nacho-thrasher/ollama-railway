#!/bin/sh

# Start socat in the background to forward port 8080 to 11434
#socat TCP-LISTEN:8080,fork TCP:localhost:11434 &

# Iniciar Ollama con menor uso de memoria (usa mmap si es posible)
exec ollama serve \
  --ctx-size 2048 \
  --batch-size 256

# Start Ollama
# exec serve

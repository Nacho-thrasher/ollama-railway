#!/bin/sh

# Iniciar Ollama con menor uso de RAM, mmap deshabilitado, y tamaño de contexto ajustado
exec ollama serve \
  --model phi3:latest \
  --ctx-size 2048 \
  --batch-size 256 \
  --threads 8 \
  --no-mmap \
  --numa \
  --parallel

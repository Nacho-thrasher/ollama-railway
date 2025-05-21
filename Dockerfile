FROM ollama/ollama:latest

# Envs
ENV OLLAMA_NUM_GPU=0
ENV OLLAMA_NUM_PARALLEL=1
ENV OLLAMA_MMAP=0
ENV OLLAMA_MAX_LOADED_MODELS=2

# Anulamos el entrypoint original (ollama)
ENTRYPOINT []

# Ollama runs on port 11434 by default
EXPOSE 11434

# Creamos carpeta de modelos por si acaso
RUN mkdir -p /root/.ollama/models

# Copiamos el script de arranque optimizado
# COPY start.sh /start.sh
# RUN chmod +x /start.sh

# Ejecutamos el script personalizado
CMD ["ollama", "serve"]

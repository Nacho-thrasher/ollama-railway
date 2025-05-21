FROM ollama/ollama:latest

# Anulamos el entrypoint original (ollama)
ENTRYPOINT []

# Ollama runs on port 11434 by default
EXPOSE 11434

# Creamos carpeta de modelos por si acaso
RUN mkdir -p /root/.ollama/models

# Copiamos el script de arranque optimizado
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Ejecutamos el script personalizado
CMD ["/start.sh"]

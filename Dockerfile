FROM ollama/ollama:latest

# Ollama runs on port 11434 by default
EXPOSE 11434

# Ensure the models directory exists
RUN mkdir -p /root/.ollama/models

# The ollama binary is integrated into the image and should be called directly
#CMD ["serve"]

# Copiamos script de arranque
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Entramos con el script de arranque que usa socat y ollama
CMD ["/start.sh"]
FROM ollama/ollama:latest

EXPOSE 11434

# Ensure the models directory exists
RUN mkdir -p /root/.ollama/models

# The ollama binary is integrated into the image and should be called directly
CMD ["serve"]
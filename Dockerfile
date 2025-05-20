FROM ollama/ollama:latest

EXPOSE 11434

# Ensure the models directory exists
RUN mkdir -p /root/.ollama/models

# Make sure the ollama binary is executable
RUN chmod +x /usr/local/bin/ollama || echo "Ollama binary not found at expected location"

# Use a more explicit command execution with fallback to see what's going on
CMD ["/bin/sh", "-c", "which ollama && ollama serve || echo 'Ollama binary not found in PATH' && echo 'PATH:' && echo $PATH && ls -la /usr/local/bin/"]
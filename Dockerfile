FROM ollama/ollama:latest

# Expose both ports - 11434 is Ollama's default, 8080 is what Railway expects
EXPOSE 11434
EXPOSE 8080

# Ensure the models directory exists
RUN mkdir -p /root/.ollama/models

# Install socat to redirect port 8080 to 11434
RUN apt-get update && apt-get install -y socat

# Use a shell script to start both socat and ollama
COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
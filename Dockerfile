FROM ollama/ollama:latest

EXPOSE 11434

RUN mkdir -p /root/.ollama/models

CMD ["ollama", "serve"]
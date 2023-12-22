# Use the official Ubuntu base image
FROM ubuntu:latest

# Install dependencies and set environment variables
RUN apt-get update && apt-get install -y curl

# Set environment variables
ENV LLM=$LLM
ENV OLLAMA_BASE_URL=$OLLAMA_BASE_URL

# Copy ollama binary from the ollama image
COPY --from=ollama/ollama:latest /bin/ollama /bin/ollama

# Create a bash script to pull the ollama model
RUN echo '#!/bin/bash\n\
llm=$LLM\n\
url=$OLLAMA_BASE_URL\n\
echo "Pulling ollama model $llm using $url"\n\
if [[ -n "$llm" && -n "$url" && "$llm" != "gpt-4" && "$llm" != "gpt-3.5" ]]; then\n\
  echo "OLLAMA_HOST=$url /bin/ollama pull $llm"\n\
else\n\
  echo "OLLAMA model will only be pulled if both LLM and OLLAMA_BASE_URL are set and the LLM model is not gpt"\n\
fi' > /pull_model.sh

# Make the script executable
RUN chmod +x /pull_model.sh

# Set the entry point to the bash script
ENTRYPOINT ["/pull_model.sh"]

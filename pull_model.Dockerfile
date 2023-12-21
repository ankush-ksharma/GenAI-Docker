#syntax = docker/dockerfile:1.4

# Stage 1: Use ollama/ollama image
FROM ollama/ollama:latest AS ollama

# Stage 2: Use ubuntu as base image
FROM ubuntu:latest

# Copy ollama binary from Stage 1
COPY --from=ollama /bin/ollama ./bin/ollama

# Add the bash script directly in the Dockerfile
RUN echo '#!/bin/bash\n\
llm=$LLM\n\
url=$OLLAMA_BASE_URL\n\
echo "pulling ollama model $llm using $url"\n\
if [[ -n "$llm" && -n "$url" && "$llm" != "gpt-4" && "$llm" != "gpt-3.5" ]]; then\n\
  echo "OLLAMA_HOST=$url ./bin/ollama pull $llm"\n\
else\n\
  echo "OLLAMA model only pulled if both LLM and OLLAMA_BASE_URL are set and the LLM model is not gpt"\n\
fi' > pull_model.sh

<<<<<<< Updated upstream
(try
  (let [llm (get (System/getenv) "LLM")
        url (get (System/getenv) "OLLAMA_BASE_URL")]
    (println (format "pulling ollama model %s using %s" llm url))
    (if (and llm url (not (#{"gpt-4" "gpt-3.5" "claudev2"} llm)))

      ;; ----------------------------------------------------------------------
      ;; just call `ollama pull` here - create OLLAMA_HOST from OLLAMA_BASE_URL
      ;; ----------------------------------------------------------------------
      ;; TODO - this still doesn't show progress properly when run from docker compose

      (let [done (async/chan)]
        (async/go-loop [n 0]
          (let [[v _] (async/alts! [done (async/timeout 5000)])]
            (if (= :stop v) :stopped (do (println (format "... pulling model (%ss) - will take several minutes" (* n 10))) (recur (inc n))))))
        (process/shell {:env {"OLLAMA_HOST" url} :out :inherit :err :inherit} (format "./bin/ollama pull %s" llm))
        (async/>!! done :stop))

      (println "OLLAMA model only pulled if both LLM and OLLAMA_BASE_URL are set and the LLM model is not gpt")))
  (catch Throwable _ (System/exit 1)))
EOF

ENTRYPOINT ["bb", "-f", "pull_model.clj"]
=======
# Make the script executable
RUN chmod +x ./pull_model.sh
>>>>>>> Stashed changes

# Run the script when a container is started from the image
ENTRYPOINT ["./pull_model.sh"]

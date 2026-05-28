exec code-server \
  --bind-addr 0.0.0.0:8080 \
  --auth ${CS_AUTH:-none} \
  /home/coder/workspace

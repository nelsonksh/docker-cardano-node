docker run --detach \
  --name cardano-node \
  -v node-data:/data/db \
  -v node-ipc:/ipc \
  -e NETWORK=preprod \
  -p 3001:3001 \
  -p 5000:5000 \
  blinklabs-node

curl "http://localhost:5000/run-script?name=Dave"

curl -X POST -H "Content-Type: application/json" -d '{"name":"Dave1","age":65}' http://localhost:5000/greet

curl -X POST -H "Content-Type: application/json" -d '{"TxIn":"fce52412b9142577b80d3468dae2c54a251e3622dff80eafb0dedbb802db6f58#3"}' http://localhost:5000/tx

docker exec -it cardano-node cat /var/log/entrypoint.log

docker logs -f cardano-node

alias cardano-cli="docker run --rm -ti \
  -e NETWORK=preprod \
  -v node-ipc:/ipc \
  ghcr.io/blinklabs-io/cardano-node cli"
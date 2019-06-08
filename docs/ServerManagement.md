# Server Management

## Build New Version

Posting the clients also updates the server and the reflector.

```
user=richard
server=crucible.oho.life
port=1001

ssh -p $port $user@$server << EOF
cd crucible
git pull
./scripts/BuildAndPostClients tag client post
EOF
```
# Server Management

## Tag New Version

Use this command to tag a new version of the client and server.

```
./scripts/TagNewVersion.sh
```

## Build New Version

Use this command to update the clients and servers to the most recent tag.

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
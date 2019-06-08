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

## Updating Servers

Servers are checked out on `master` so this needs running immediately after the tag is pushed.

```
user=richard
server=server1.oho.life

ssh -n $user@$server '~/checkout/OneLife/scripts/remoteServerShutdown.sh'
ssh -n $user@$server '~/checkout/OneLife/scripts/remoteServerUpdate.sh'
ssh -n $user@$server '~/checkout/OneLife/scripts/remoteServerStartup.sh'
```
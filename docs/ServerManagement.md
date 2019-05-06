# Server Management

## Updating Servers

Servers are checked out on `master` so this needs running immediately after the tag is pushed.

```
user=richard
server=server1.oho.life

ssh -n $user@$server '~/checkout/OneLife/scripts/remoteServerShutdown.sh'
ssh -n $user@$server '~/checkout/OneLife/scripts/remoteServerUpdate.sh'
ssh -n $user@$server '~/checkout/OneLife/scripts/remoteServerStartup.sh'
```
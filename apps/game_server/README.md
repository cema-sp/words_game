# GameServer
Server for Words Game

## Running Server
### Running from IEx

~~~
iex -S mix
> GameServer.Application.start([], [])
~~~

### Running release

~~~
../../_build/dev/rel/game_server/bin/game_server
~~~

## Releasing

`mix release`

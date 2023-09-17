# Running

## Run the Sinatra server

```shell
$ rackup -p4567
```

Access at [http://localhost:4567](http://localhost:4567)

## Run the template for reference

```shell
$ cd doc/template/biznex/
$ python -m SimpleHTTPServer
```

Access at [http://localhost:8000](http://localhost:8000)

# DevOps

## Maintenance mode

Enable Maintenance mode

```shell
$ bundle exec cap production maintenance:start
```

Disable Maintenance mode

```shell
$ bundle exec cap production maintenance:stop
```

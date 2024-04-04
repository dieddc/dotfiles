set positional-arguments

# Just: Dump json file formatted
just-json *name:
  just -f {{name}}{{ if name == "" { "justfile" } else { ".justfile" }  }} --dump --dump-format json --unstable | fx

# Docker: remove pruned images older then 10 days
docker-image-prune:
  docker image prune --filter "until=240h"

# Linux: Get cpu information
lnx-get-info-cpu:
  lscpu


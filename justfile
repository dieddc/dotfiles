
push-wip:
  git add *
  git commit -am wip
  git push

push:
  pnpx better-commits
  git push

test-bootstrap:
  curl -fsSL https://raw.githubusercontent.com/dieddc/dotfiles/master/bootstrap.sh | bash
  # bash <(curl -fsSL https://raw.githubusercontent.com/dieddc/dotfiles/master/bootstrap.sh)

c0:
  docker run --rm -it -v ./bootstrap.sh:/root/bootstrap.sh -w /root --entrypoint ./bootstrap.sh local/base-dev:latest /bin/bash

c1:
  # Eerst nieuwe container starten en bootstrap draaien voor aanmaak user, deze sessie late open staan
  docker run -it --name test-bootstrap -v ./bootstrap.sh:/root/bootstrap.sh -w /root -u root local/base-dev:latest /bin/bash
c2:
  # Dan starten als user dev
  docker exec -it -u dev -w /home/ddc test-bootstrap /bin/bash
c3:
  # Remove container
  docker container rm test-bootstrap
c4:
  docker run --rm -it --name test-bootstrap -v ./bootstrap.sh:/tmp/bootstrap.sh local/base-dev-git:latest /bin/bash
  #docker run --rm -it -v ./bootstrap.sh:/tmp/bootstrap.sh --entrypoint /tmp/bootstrap.sh local/base-dev-user:latest /bin/bash
c5:
  docker exec -it test-bootstrap

install-examples: 
  rm -rf temp/dotfiles
  degit https://github.com/felipecrs/dotfiles temp/dotfiles/felipecrs
  degit https://github.com/mkasberg/dotfiles temp/dotfiles/mkasberg
  degit https://github.com/japananh/dotfiles temp/dotfiles/japananh
  degit https://github.com/DoomHammer/dotfiles temp/dotfiles/DoomHammer

vm-restart: 
  lxc restore test test-base
  lxc exec test -- sudo --user ubuntu --login

vm-login: 
  lxc exec test -- sudo --user ubuntu --login

vm-build: 
  lxc delete -f test
  lxc launch ubuntu:20.04 test -p default -p ssh-access
  lxc stop test && lxc snapshot test test-base && lxc start test
  config device add test dotfiles disk source=/home/ddc/dev/dotfiles path=/home/ubuntu/dotfiles shift=true

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

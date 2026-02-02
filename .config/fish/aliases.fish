alias docker_gpu='sudo docker run -it --network=host --device=/dev/kfd --device=/dev/dri --group-add=video --ipc=host --cap-add=SYS_PTRACE --security-opt seccomp=unconfined -v $HOME/dockerx:/dockerx'
alias lazypodman='DOCKER_HOST=unix:///run/user/1000/podman/podman.sock lazydocker'
# alias jcl 'journalctl -f -o json --since "1 hour ago" | lnav'

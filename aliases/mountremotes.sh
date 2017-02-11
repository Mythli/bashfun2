umount ~/Remotes/hetzner & mount_sshfs -o port=22,reconnect,uid=501,gid=20,follow_symlinks,allow_other,IdentityFile=~/.ssh/id_rsa,volname="hetzner" ~/Remotes/hetzner root@mythli.net:/
umount ~/Remotes/devbox & mount_sshfs -o port=12022,reconnect,uid=501,gid=20,follow_symlinks,allow_other,IdentityFile=~/.ssh/id_rsa,volname="devbox" ~/Remotes/devbox root@mythli.net:/
umount ~/Remotes/tobias & mount_sshfs -o port=13022,reconnect,uid=501,gid=20,follow_symlinks,allow_other,IdentityFile=~/.ssh/id_rsa,volname="prodbox" ~/Remotes/prodbox root@mythli.net:/

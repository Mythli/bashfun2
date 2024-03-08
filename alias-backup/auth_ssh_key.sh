cat ~/.ssh/id_rsa.pub | $1 "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"

#!/bin/bash

wget https://github.com/LarissaBlockchain/Core/releases/download/v1.12.1/geth -O /usr/local/bin/larissa-geth

chmod +x /usr/local/bin/larissa-geth

cat <<EOF > /root/startnode.sh
#!/bin/bash
if [ -z "\$1" ]; then
  echo "Input your key."
  exit 1
fi

larissa-geth --larissa.node=1 --larissa.node.user.key="\$1"
EOF

chmod +x /root/startnode.sh

echo "Start your node with '/root/startnode.sh yourkey'"

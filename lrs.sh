#!/bin/bash

echo "Stahujem Larissa Geth z GitHubu..."
wget https://github.com/LarissaBlockchain/Core/releases/download/v1.12.1/geth -O /usr/local/bin/larissa-geth

echo "Nastavujem práva na binárku..."
chmod +x /usr/local/bin/larissa-geth

echo "Vytváram spúšťací skript pre node..."

cat <<EOF > /usr/local/bin/startnode
#!/bin/bash
if [ -z "\$1" ]; then
  echo "Prosím zadajte svoj Larissa node user key ako parameter."
  exit 1
fi

larissa-geth --larissa.node=1 --larissa.node.user.key="\$1"
EOF

chmod +x /usr/local/bin/startnode

echo "Start your node with './startnode yourkey'"

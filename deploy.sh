#!/bin/bash

# Menghubungkan ke server dan menjalankan deploy.sh
ssh -p "${SERVER_PORT}" "${SERVER_USERNAME}"@"${SERVER_HOST}" -i key.txt -t -o StrictHostKeyChecking=no << 'ENDSSH'
# Pindah ke direktori ecommerce (sesuaikan jika deploy.sh ada di folder lain)
cd ~/ecommerce-leex

# Memastikan bahwa file deploy.sh ada dan memiliki hak eksekusi
if [ -f deploy.sh ]; then
    echo "Menjalankan deploy.sh..."
    ./deploy.sh   # Menjalankan skrip deploy.sh
else
    echo "❌ deploy.sh tidak ditemukan!"
    exit 1
fi

exit
ENDSSH

# Mengecek status eksekusi SSH
if [ $? -eq 0 ]; then
  echo "✅ Deployment successful."
  exit 0
else
  echo "❌ Deployment failed."
  exit 1
fi

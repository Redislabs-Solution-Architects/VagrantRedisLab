mkdir ./$(hostname) && \
tar -xf $1 -C ./$(hostname) && \
cd ./$(hostname) && \
./install.sh -y
cd ..
chmod -R 777 ./$(hostname)
rm -rf ./$(hostname)
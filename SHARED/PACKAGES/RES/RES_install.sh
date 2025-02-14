echo "Executing $0"
rm -rf ./$(hostname -s) && \
mkdir ./$(hostname -s) && \
tar -xf $1 -C ./$(hostname -s) && \
cd ./$(hostname -s) && \
./install.sh -y
cd ..
chmod -R 777 ./$(hostname -s)
rm -rf ./$(hostname -s)
sudo rm -rf ./data

sudo mkdir -p ./data/eldata/data 
sudo mkdir -p ./data/eldata/logs
sudo chown 1000:1000 ./data/eldata/data
sudo chown 1000:1000 ./data/eldata/logs
sudo chmod -R 777 data


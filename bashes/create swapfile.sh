#!/bin/bash
sudo fallocate -l 2G /swapfile
wait
sudo chmod 600 /swapfile
wait
sudo mkswap /swapfile
wait
sudo swapon /swapfile
wait
swapon --show
wait
sudo cp /etc/fstab /etc/fstab.back
wait
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
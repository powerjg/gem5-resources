#!/bin/bash

sudo ndctl create-namespace -f -enamespace0.0 -m devdax

# Enable users to read/write to the device
sudo chmod a+rw /dev/dax0.0
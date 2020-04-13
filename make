#!/usr/bin/env bash
# remove previous run.sh
rm ./run.sh

# copy src/main.sh as baseline run.sh
cp ./src/main.sh ./run.sh

# append src/get_* functions to new run.sh
for f in ./src/get_*; do tail -n +2 "$f" >> ./run.sh; done

# make executable for testing
chmod +x ./run.sh

# sanity check test
./run.sh testonly

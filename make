#!/usr/bin/env bash
# remove previous run.sh, initialize
rm ./run.sh
echo "#!/usr/bin/env bash" > ./run.sh

# append src/get_* functions to run.sh
for f in ./src/get_*; do tail -n +2 "$f" >> ./run.sh; done

# append src/main.sh to run.sh
tail -n +5 ./src/main.sh >> ./run.sh

# make executable for testing
chmod +x ./run.sh

# sanity check test
./run.sh testonly

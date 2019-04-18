#!/bin/bash

# setup our working directory
cd ~
mkdir go
cd go
mkdir libs projects objectbox

# download Go
wget https://dl.google.com/go/go1.12.1.linux-armv6l.tar.gz
tar xvf go1.12.1.linux-armv6l.tar.gz
rm go1.12.1.linux-armv6l.tar.gz

# set Go's environment variables
echo 'export GOROOT=$HOME/go/go' >> ~/.bashrc
echo 'export GOPATH=$HOME/go/libs' >> ~/.bashrc
echo 'export PATH=$GOPATH/bin:$GOROOT/bin:$PATH' >> ~/.bashrc
source ~/.bashrc

# get the ObjectBox binary library
cd objectbox
IFS=
read -d '' updateobjectbox <<"EOF"
#!/bin/bash
curl https://raw.githubusercontent.com/objectbox/objectbox-c/master/download.sh > download.sh
chmod +x download.sh
./download.sh --quiet
rm download.sh
mv lib/libobjectbox.so .
rm -r download lib
EOF
printf $updateobjectbox > update-objectbox.sh
chmod +x update-objectbox.sh
./update-objectbox.sh

# get the ObjectBox Go library
CGO_LDFLAGS="-L$HOME/go/objectbox" go get -v github.com/objectbox/objectbox-go/...
go get github.com/google/flatbuffers/go
go install github.com/objectbox/objectbox-go/cmd/objectbox-gogen/

# create the demo project
cd ../projects
mkdir objectbox-go-test
cd objectbox-go-test
wget https://gist.githubusercontent.com/sigalor/49fc6d028e5b36ad5096baf55d248cac/raw/b3c93f7c6603b1b7d1065fd0e06bc425ad993057/main.go
objectbox-gogen -source main.go
CGO_LDFLAGS="-L$HOME/go/objectbox" go build
LD_LIBRARY_PATH="$HOME/go/objectbox:$LD_LIBRARY_PATH" ./objectbox-go-test

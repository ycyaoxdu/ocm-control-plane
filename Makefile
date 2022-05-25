BINARYDIR := bin

all: clean vendor build 
.PHONY: all
build: 
	$(shell if [ ! -e $(BINARYDIR) ];then mkdir -p $(BINARYDIR); fi)
	go build -o bin/ocm-controlplane main.go
	$(shell ./hack/build.sh)
.PHONY: build

clean:
	rm -rf bin .ocmconfig apiserver.local.config 
.PHONY: clean

vendor: 
	go mod tidy
	go mod vendor
.PHONY: vendor

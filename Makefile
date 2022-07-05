BINARYDIR := bin

all: clean vendor build run
.PHONY: all

run:
	$(shell hack/local-up-cluster.sh)
.PHONY: run

build: 
	$(shell if [ ! -e $(BINARYDIR) ];then mkdir -p $(BINARYDIR); fi)
	go build -o bin/ocm-controlplane main.go 
.PHONY: build

clean:
	rm -rf bin .ocmconfig
.PHONY: clean

vendor: 
	go mod tidy -go=1.16 && go mod tidy -go=1.17
	go mod vendor
.PHONY: vendor

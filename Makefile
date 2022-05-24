BINARYDIR := bin

all: clean vendor build 
.PHONY: all
build: WHAT ?= ./cmd/...
build: 
	$(shell if [ ! -e $(BINARYDIR) ];then mkdir -p $(BINARYDIR); fi)
	go build -o bin $(WHAT)
.PHONY: build

clean:
	rm -rf bin .ocmconf
.PHONY: clean

vendor: 
	go mod tidy
	go mod vendor
.PHONY: vendor

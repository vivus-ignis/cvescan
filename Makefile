BUILD_OPTS := --debug --static --link-flags "-ldl -L/openssl -static" -Dbuild

cvescan:
	docker build -t cvescan-build .
#	docker run --rm -u $(USER) \
#	  -v $(CURDIR):/tmp/cvescan \
#	  -w /tmp/cvescan cvescan-build \
#	  shards install
	docker run --rm -u $(USER) \
	  -v $(CURDIR):/tmp/cvescan \
	  -w /tmp/cvescan cvescan-build \
	  crystal build $(BUILD_OPTS) ./src/cvescan.cr

cacert.pem:
	curl https://curl.haxx.se/ca/cacert.pem > $@

clean:
	rm -f cvescan

test:
	crystal spec

debug-debian: cvescan
	time docker run --rm -u $(USER) -ti \
	  -v $(CURDIR)/cvescan:/usr/bin/cvescan \
	  -e CVESCAN_DEBUG=1 cvescan-debian gdb /usr/bin/cvescan

interact-debian: cvescan
	docker run --rm -ti \
	  -v $(CURDIR)/cvescan:/usr/bin/cvescan \
	  -v $(CURDIR)/cacert.pem:/usr/local/ssl/cert.pem \
	  -e CVESCAN_DEBUG=1 cvescan-debian 

interact-alpine: cvescan
	docker run --rm -ti \
	  -v $(CURDIR)/cvescan:/usr/bin/cvescan \
	  -v $(CURDIR)/cacert.pem:/usr/local/ssl/cert.pem \
	  -e CVESCAN_DEBUG=1 cvescan-alpine

test-debian: cvescan cacert.pem
	docker build -t cvescan-debian -f Dockerfile.debian .
	docker run --rm -u $(USER) \
	  -v $(CURDIR)/cvescan:/usr/bin/cvescan -v $(CURDIR)/tmp:/tmp \
	  -v $(CURDIR)/cacert.pem:/usr/local/ssl/cert.pem \
	  -e CVESCAN_DEBUG=1 cvescan-debian /usr/bin/cvescan

test-ubuntu: cvescan cacert.pem
	docker build -t cvescan-ubuntu -f Dockerfile.ubuntu .
	docker run --rm -u $(USER) \
	  -v $(CURDIR)/cvescan:/usr/bin/cvescan -v $(CURDIR)/tmp:/tmp \
	  -v $(CURDIR)/cacert.pem:/usr/local/ssl/cert.pem \
	  -e CVESCAN_DEBUG=1 cvescan-ubuntu /usr/bin/cvescan

test-alpine: cvescan cacert.pem
	docker build -t cvescan-alpine -f Dockerfile.alpine .
	docker run --rm -u $(USER) \
	  -v $(CURDIR)/cvescan:/usr/bin/cvescan -v $(CURDIR)/tmp:/tmp \
	  -v $(CURDIR)/cacert.pem:/usr/local/ssl/cert.pem \
	  -e CVESCAN_DEBUG=1 cvescan-alpine /usr/bin/cvescan

.PHONY: clean test debug-debian test-debian test-ubuntu test-alpine

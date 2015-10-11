all: build

build:
	@docker build --tag=quay.io/sameersbn/ffmpeg .

release: build
	@docker build --tag=quay.io/sameersbn/ffmpeg:$(shell cat VERSION) .

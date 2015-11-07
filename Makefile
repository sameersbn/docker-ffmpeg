all: build

build:
	@docker build --tag=sameersbn/ffmpeg .

release: build
	@docker build --tag=sameersbn/ffmpeg:$(shell cat VERSION) .

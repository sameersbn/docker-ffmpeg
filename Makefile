all: build

build:
	@docker build --tag=${USER}/ffmpeg .

release: build
	@docker build --tag=quay.io/${USER}/ffmpeg:$(shell cat VERSION) .

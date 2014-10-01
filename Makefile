all: build

build:
	@docker build --tag=${USER}/ffmpeg .

release: build
	@docker build --tag=${USER}/ffmpeg:$(shell date +%Y%m%d) .


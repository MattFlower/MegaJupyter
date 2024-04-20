build:
	docker build . -t mega_jupyter:latest

run:
	docker run -it -p 8888:8888 -v ./notebooks:/app mega_jupyter:latest

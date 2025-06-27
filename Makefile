build:
	docker build . -t mega_jupyter:latest

run:
	docker run -it -p 8888:8888 -v /var/run/docker.sock:/run/docker.sock mega_jupyter:latest

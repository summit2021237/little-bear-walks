default: clean build run

build:
	sudo docker build -t little-bear-walks .

run:
	mkdir -p output
	sudo docker run -it --mount type=bind,src=./output,dst=/usr/local/app/output --rm little-bear-walks

clean:
	rm -rf output

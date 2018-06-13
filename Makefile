

.PHONY: source clean build


clean:
	rm -rf ./build/sources


source:
	conan source . -sf=build/sources

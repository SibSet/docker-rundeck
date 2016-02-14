IMAGE_VERSION = latest
IMAGE = sibset/rundeck:$(IMAGE_VERSION)

.PHONY: all

all:
	$(MAKE) image
	$(MAKE) push

image:
	docker build -t $(IMAGE) --rm --force-rm ./

push:
	docker push $(IMAGE)

#!/bin/sh

docker build -t ccp-up4a-spark:v0.9 .
docker tag ccp-up4a-spark:v0.9  image-registry.internal.ccp.systems/paas/ccp-up4a-spark:v0.9
docker push image-registry.internal.ccp.systems/paas/ccp-up4a-spark:v0.9

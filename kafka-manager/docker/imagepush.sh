#!/bin/sh

PROJECT_NAME=paas
docker build -t eu.gcr.io/ccp-testenv/paas/kafka-mon .
docker tag eu.gcr.io/ccp-testenv/paas/kafka-mon eu.gcr.io/ccp-testenv/${PROJECT_NAME}
docker push eu.gcr.io/ccp-testenv/paas/kafka-mon



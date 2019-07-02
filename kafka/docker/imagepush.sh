#!/bin/sh

PROJECT_NAME=paas
docker build -t eu.gcr.io/ccp-testenv/paas/kafka .
docker tag eu.gcr.io/ccp-testenv/paas/kafka eu.gcr.io/ccp-testenv/${PROJECT_NAME}
docker push eu.gcr.io/ccp-testenv/paas/kafka



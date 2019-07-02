#!/bin/sh

PROJECT_NAME=paas
docker build -t eu.gcr.io/ccp-testenv/paas/spark .
docker tag eu.gcr.io/ccp-testenv/paas/spark eu.gcr.io/ccp-testenv/${PROJECT_NAME}
docker push eu.gcr.io/ccp-testenv/paas/spark



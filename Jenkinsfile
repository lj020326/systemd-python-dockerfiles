#!/usr/bin/env groovy

//@Library("pipeline-automation-lib@develop")_
@Library("pipeline-automation-lib")_

import com.dettonville.api.pipeline.utils.logging.LogLevel
import com.dettonville.api.pipeline.utils.logging.Logger
import com.dettonville.api.pipeline.utils.JsonUtils

Logger.init(this, LogLevel.INFO)
Logger log = new Logger(this)

// ref: https://stackoverflow.com/questions/40261710/getting-current-timestamp-in-inline-pipeline-script-using-pipeline-plugin-of-hud
Date now = new Date()
String buildDate = now.format("yyyyMMdd", TimeZone.getTimeZone('UTC'))
String buildId = "${buildDate}.${BUILD_NUMBER}"
log.info("buildId=${buildId}")

String configYmlStr="""
---
pipeline:
  alwaysEmailList: ljohnson@dettonville.org
  logLevel: DEBUG
  buildId: "${buildId}"

  buildArgs:
    IMAGE_REGISTRY: media.johnson.int:5000
    BUILD_ID: "${buildId}"

  buildImageList:
    - buildImageLabel: openrc-alpine
      buildDir: openrc/alpine
      dockerFile: Dockerfile
    - buildImageLabel: openrc-alpine-python
      buildDir: openrc/alpine
      dockerFile: python.Dockerfile

    - buildImageLabel: aports-dev
      buildDir: aports-dev
      dockerFile: Dockerfile
    - buildImageLabel: aports-dev-python
      buildDir: aports-dev
      dockerFile: python.Dockerfile

    - buildImageLabel: centos7-systemd
      buildDir: systemd/centos
      dockerFile: 7.Dockerfile
    - buildImageLabel: centos8-systemd
      buildDir: systemd/centos
      dockerFile: 8.Dockerfile
    - buildImageLabel: centos9-systemd
      buildDir: systemd/centos
      dockerFile: 9.Dockerfile

    - buildImageLabel: redhat7-systemd
      buildDir: systemd/redhat
      dockerFile: 7.Dockerfile
    - buildImageLabel: redhat8-systemd
      buildDir: systemd/redhat
      dockerFile: 8.Dockerfile
    - buildImageLabel: redhat9-systemd
      buildDir: systemd/redhat
      dockerFile: 9.Dockerfile

    - buildImageLabel: fedora35-systemd
      buildDir: systemd/fedora
      dockerFile: 35.Dockerfile
    - buildImageLabel: fedora36-systemd
      buildDir: systemd/fedora
      dockerFile: 36.Dockerfile

    - buildImageLabel: debian8-systemd
      buildDir: systemd/debian
      dockerFile: 8.Dockerfile
    - buildImageLabel: debian9-systemd
      buildDir: systemd/debian
      dockerFile: 9.Dockerfile
    - buildImageLabel: debian10-systemd
      buildDir: systemd/debian
      dockerFile: 10.Dockerfile
    - buildImageLabel: debian11-systemd
      buildDir: systemd/debian
      dockerFile: 11.Dockerfile
    - buildImageLabel: debian12-systemd
      buildDir: systemd/debian
      dockerFile: 12.Dockerfile
    - buildImageLabel: debian-sid-systemd
      buildDir: systemd/debian
      dockerFile: sid.Dockerfile

    - buildImageLabel: ubuntu1604-systemd
      buildDir: systemd/ubuntu
      dockerFile: 16.04.Dockerfile
    - buildImageLabel: ubuntu1804-systemd
      buildDir: systemd/ubuntu
      dockerFile: 18.04.Dockerfile
    - buildImageLabel: ubuntu2004-systemd
      buildDir: systemd/ubuntu
      dockerFile: 20.04.Dockerfile
    - buildImageLabel: ubuntu2204-systemd
      buildDir: systemd/ubuntu
      dockerFile: 22.04.Dockerfile

    ## systemd images with python installed
    - buildImageLabel: centos7-systemd-python
      buildDir: systemd/centos
      dockerFile: 7.python.Dockerfile
    - buildImageLabel: centos8-systemd-python
      buildDir: systemd/centos
      dockerFile: 8.python.Dockerfile
    - buildImageLabel: centos9-systemd-python
      buildDir: systemd/centos
      dockerFile: 9.python.Dockerfile

    - buildImageLabel: redhat7-systemd-python
      buildDir: systemd/redhat
      dockerFile: 7.python.Dockerfile
    - buildImageLabel: redhat8-systemd-python
      buildDir: systemd/redhat
      dockerFile: 8.python.Dockerfile
    - buildImageLabel: redhat9-systemd-python
      buildDir: systemd/redhat
      dockerFile: 9.python.Dockerfile

    - buildImageLabel: fedora35-systemd-python
      buildDir: systemd/fedora
      dockerFile: 35.python.Dockerfile
    - buildImageLabel: fedora8-systemd-python
      buildDir: systemd/fedora
      dockerFile: 36.python.Dockerfile

    - buildImageLabel: debian8-systemd-python
      buildDir: systemd/debian
      dockerFile: 8.python.Dockerfile
    - buildImageLabel: debian9-systemd-python
      buildDir: systemd/debian
      dockerFile: 9.python.Dockerfile
    - buildImageLabel: debian10-systemd-python
      buildDir: systemd/debian
      dockerFile: 10.python.Dockerfile
    - buildImageLabel: debian11-systemd-python
      buildDir: systemd/debian
      dockerFile: 11.python.Dockerfile
    - buildImageLabel: debian12-systemd-python
      buildDir: systemd/debian
      dockerFile: 12.python.Dockerfile

    - buildImageLabel: ubuntu1804-systemd-python
      buildDir: systemd/ubuntu
      dockerFile: 18.04.Dockerfile
    - buildImageLabel: ubuntu2004-systemd-python
      buildDir: systemd/ubuntu
      dockerFile: 20.04.python.Dockerfile
    - buildImageLabel: ubuntu2204-systemd-python
      buildDir: systemd/ubuntu
      dockerFile: 22.04.python.Dockerfile

"""

Map configSettings = readYaml text: configYmlStr
Map config=configSettings.pipeline

log.info("config=${JsonUtils.printToJsonString(config)}")

buildDockerImage(config)

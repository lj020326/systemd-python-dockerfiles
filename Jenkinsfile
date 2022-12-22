#!/usr/bin/env groovy

//@Library("pipeline-automation-lib@develop")_
@Library("pipeline-automation-lib")_

import com.dettonville.api.pipeline.utils.logging.LogLevel
import com.dettonville.api.pipeline.utils.logging.Logger
import com.dettonville.api.pipeline.utils.JsonUtils

Logger.init(this, LogLevel.INFO)
Logger log = new Logger(this)

String configYmlStr="""
---
pipeline:
  alwaysEmailList: ljohnson@dettonville.org
  logLevel: DEBUG

  buildImageList:
    - buildImageLabel: centos7-systemd
      buildDir: systemd/centos
      dockerFile: 7.Dockerfile
    - buildImageLabel: centos8-systemd
      buildDir: systemd/centos
      dockerFile: 8.Dockerfile

    - buildImageLabel: redhat7-systemd
      buildDir: systemd/redhat
      dockerFile: 7.Dockerfile
    - buildImageLabel: redhat8-systemd
      buildDir: systemd/redhat
      dockerFile: 8.Dockerfile

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

    - buildImageLabel: redhat7-systemd-python
      buildDir: systemd/redhat
      dockerFile: 7.python.Dockerfile
    - buildImageLabel: redhat8-systemd-python
      buildDir: systemd/redhat
      dockerFile: 8.python.Dockerfile

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

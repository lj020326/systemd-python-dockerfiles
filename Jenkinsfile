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
      dockerFile: systemd/centos/7.Dockerfile
    - buildImageLabel: centos8-systemd
      dockerFile: systemd/centos/8.Dockerfile
    - buildImageLabel: redhat7-systemd
      dockerFile: systemd/redhat/7.Dockerfile
    - buildImageLabel: redhat8-systemd
      dockerFile: systemd/redhat/8.Dockerfile
    - buildImageLabel: fedora35-systemd
      dockerFile: systemd/fedora/35.Dockerfile
    - buildImageLabel: fedora36-systemd
      dockerFile: systemd/fedora/36.Dockerfile

    - buildImageLabel: debian8-systemd
      dockerFile: systemd/debian/8.Dockerfile
    - buildImageLabel: debian9-systemd
      dockerFile: systemd/debian/9.Dockerfile
    - buildImageLabel: debian10-systemd
      dockerFile: systemd/debian/10.Dockerfile
    - buildImageLabel: debian11-systemd
      dockerFile: systemd/debian/11.Dockerfile
    - buildImageLabel: debian12-systemd
      dockerFile: systemd/debian/12.Dockerfile
    - buildImageLabel: systemd-debian-sid
      dockerFile: systemd/debian/sid.Dockerfile
    - buildImageLabel: ubuntu1604-systemd
      dockerFile: systemd/ubuntu/16.04.Dockerfile
    - buildImageLabel: ubuntu1804-systemd
      dockerFile: systemd/ubuntu/18.04.Dockerfile
    - buildImageLabel: ubuntu2004-systemd
      dockerFile: systemd/ubuntu/20.04.Dockerfile
    - buildImageLabel: ubuntu2204-systemd
      dockerFile: systemd/ubuntu/22.04.Dockerfile

    ## systemd images with python installed
    - buildImageLabel: centos7-systemd-python
      dockerFile: systemd/centos/7.python.Dockerfile
    - buildImageLabel: centos8-systemd-python
      dockerFile: systemd/centos/8.python.Dockerfile
    - buildImageLabel: redhat7-systemd-python
      buildDir: systemd/redhat
      dockerFile: systemd/redhat/7.python.Dockerfile
    - buildImageLabel: redhat8-systemd-python
      dockerFile: systemd/redhat/8.python.Dockerfile
    - buildImageLabel: fedora35-systemd-python
      dockerFile: systemd/fedora/35.python.Dockerfile
    - buildImageLabel: fedora8-systemd-python
      dockerFile: systemd/fedora/36.python.Dockerfile

    - buildImageLabel: debian8-systemd-python
      dockerFile: systemd/debian/8.python.Dockerfile
    - buildImageLabel: debian9-systemd-python
      dockerFile: systemd/debian/9.python.Dockerfile
    - buildImageLabel: debian10-systemd-python
      dockerFile: systemd/debian/10.python.Dockerfile
    - buildImageLabel: debian11-systemd-python
      dockerFile: systemd/debian/11.python.Dockerfile
    - buildImageLabel: debian12-systemd-python
      dockerFile: systemd/debian/12.python.Dockerfile

    - buildImageLabel: ubuntu1804-systemd-python
      dockerFile: systemd/ubuntu/18.04.Dockerfile
    - buildImageLabel: ubuntu2004-systemd-python
      dockerFile: systemd/ubuntu/20.04.python.Dockerfile
    - buildImageLabel: ubuntu2204-systemd-python
      dockerFile: systemd/ubuntu/22.04.python.Dockerfile

"""

Map configSettings = readYaml text: configYmlStr
Map config=configSettings.pipeline

log.info("config=${JsonUtils.printToJsonString(config)}")

buildDockerImage(config)

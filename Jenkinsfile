#!/usr/bin/env groovy

//@Library("pipeline-automation-lib@develop")_
@Library("pipeline-automation-lib")_

import com.dettonville.api.pipeline.utils.logging.LogLevel
import com.dettonville.api.pipeline.utils.logging.Logger
import com.dettonville.api.pipeline.utils.JsonUtils

Logger.init(this, LogLevel.INFO)
//Logger.init(this, LogLevel.DEBUG)
Logger log = new Logger(this)

String configYmlStr="""
---
pipeline:
  alwaysEmailList: ljohnson@dettonville.org
  runInParallel: true
  logLevel: DEBUG

  buildImageList:
    - buildImageLabel: systemd-centos-7
      dockerFile: systemd/centos/7.Dockerfile
    - buildImageLabel: systemd-centos-8
      dockerFile: systemd/centos/8.Dockerfile
    - buildImageLabel: systemd-debian-8
      dockerFile: systemd/debian/8.Dockerfile
    - buildImageLabel: systemd-debian-9
      dockerFile: systemd/debian/9.Dockerfile
    - buildImageLabel: systemd-debian-10
      dockerFile: systemd/debian/10.Dockerfile
    - buildImageLabel: systemd-debian-11
      dockerFile: systemd/debian/11.Dockerfile
    - buildImageLabel: systemd-debian-12
      dockerFile: systemd/debian/12.Dockerfile
    - buildImageLabel: systemd-debian-sid
      dockerFile: systemd/debian/sid.Dockerfile
    - buildImageLabel: systemd-fedora-latest
      dockerFile: systemd/fedora/Dockerfile
    - buildImageLabel: systemd-ubuntu-16.04
      dockerFile: systemd/ubuntu/16.04.Dockerfile
    - buildImageLabel: systemd-ubuntu-18.04
      dockerFile: systemd/ubuntu/18.04.Dockerfile
    - buildImageLabel: systemd-ubuntu-20.04
      dockerFile: systemd/ubuntu/20.04.Dockerfile
    - buildImageLabel: systemd-ubuntu-22.04
      dockerFile: systemd/ubuntu/22.04.Dockerfile

"""

Map configSettings = readYaml text: configYmlStr
Map config=configSettings.pipeline

log.info("config=${JsonUtils.printToJsonString(config)}")

buildDockerImage(config)

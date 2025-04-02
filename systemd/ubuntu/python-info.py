#!/usr/bin/env python

## ref: https://gist.github.com/jprjr/7667947#file-info-py

import platform
import os

print("platform.platform()=%s" % platform.platform())
print("platform.python_version()=%s" % platform.python_version())
print("os.getuid()=%s" % os.getuid())

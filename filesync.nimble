# Package

version       = "0.1.0"
author        = "Yongcheng Ma"
description   = "A simple directory sync tool , sync between hosts"
license       = "MIT"
srcDir        = "src"
bin           = @["filesync_server","filesync_client"]



# Dependencies

requires "nim >= 0.20.2"

import parseopt, os, strutils
import logging
import types,netutil
proc writeHelp() =
    write(stdout,"Usage " & getAppFilename().splitPath().tail & "\n" & """ 
       --port -p=port  specify the remote port
       --host -r=host  specify the remote host
       --dir  -d=directory specify the directory
       --verbose -v    verbose mode
       --second -s=seconds specify the time bewteen each sync
       --help -h          this help message""" & "\n")
if isMainModule:
    var
        port :int
        sync_second:int = 10
        dir  :string
        host :string
        verbose :bool =false
    var opt=initOptParser("")
    for kind,key,val in opt.getopt():
        case kind
        of cmdLongOption, cmdShortOption:
            case key
            of "help", "h":
                writeHelp()
                quit(0)
            of "verbose", "v":
                verbose=true
            of "port", "p":
                try:
                    port=val.parseInt()
                except:
                    stdout.writeLine("the port paramter " & val & " is not an integer")
                    quit(0)
            of "second", "s":
                try:
                    sync_second=val.parseInt()
                except:
                    stdout.writeLine("the second paramter " & val & " is not an integer")
                    quit(0)
            of "dir", "d":
                dir=val
            of "host", "r":
                host=val
            else:
                stdout.write("Unknow opt " & key & "\n")
                writeHelp()
                quit(0)
        of cmdEnd: break
        else:
                writeHelp()
                quit(0)
    if verbose:
       setVerboseLog()
    var client=newSocket()
    client.connect(host,Port(port))
    while true:
        client.sendCmd("md5") 
        var lmd5=newfiletable(dir)
        var rmd5=parseJson(client.readString())
        info $lmd5
        info $rmd5
        for k,v in pairs(rmd5):
                if lmd5.hasKey(k):
                        if lmd5[k].md5 != v["md5"].getStr():
                                info("sync file " & k)
                                client.sendCmd("download " & k)
                                let fcontent=client.readString()
                                writeFile(dir.joinPath(k),fcontent) 
                else:
                        info("sync file " & k)
                        client.sendCmd("download " & k)
                        let fcontent=client.readString()
                        let pparent=dir.joinPath(k).parentDir()
                        if not existsDir(pparent):
                                createDir(pparent)
                        writeFile(dir.joinPath(k),fcontent)
        sleep(1000*sync_second)
        info("sync file ...")
        

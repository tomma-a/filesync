import parseopt, os, strutils
import logging
import types,netutil
proc writeHelp() =
    write(stdout,"Usage " & getAppFilename().splitPath().tail & "\n" & """ 
       --port -p=port  specify the port
       --dir  -d=directory specify the directory
       --verbose -v  specify verbose mode
       --help -h          this help message""" & "\n")
if isMainModule:
    var
        port :int
        dir  :string
        verbose: bool =false
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
                    stdout.writeLine("the port paramter " & val & " is not a integer")
                    quit(0)
            of "dir", "d":
                dir=val
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
    var lmd5=newfiletable(dir)
    info %(lmd5)
    var server=newSocket()
    server.bindAddr(Port(port))
    server.listen()
    var cthreads:seq[Thread[ServerParam]] = @[]
    var clients:seq[Socket] = @[]
    var md5thread:Thread[Umd5Param]
    createThread(md5thread,updateLmd5,(ori:lmd5.addr,dir:dir))
    while true:
       var client:Socket
       server.accept(client)
       info  client.getLocalAddr()
       cthreads.add(Thread[ServerParam]())
       createThread(cthreads[cthreads.len-1],serverHandler,(client,lmd5.addr,verbose,dir))
       clients.add(client)
    

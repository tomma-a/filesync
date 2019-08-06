import net,nativesockets,strutils,json, os, logging
import types
export net,nativesockets
proc readExact*(s:Socket,ilen:int):string
proc readString*(s:Socket):string =
     var ilen:int
     discard s.recv(ilen.addr,sizeof(ilen))
     if (ilen == -1):
         info "error reading"
         return ""
     return readExact(s,ilen)
proc readExact*(s:Socket,ilen:int):string =
     result=newString(ilen)
     discard s.recv(result,ilen)
proc sendCmd*(s:Socket,cmd:string) =
     s.send(cmd & "\r\n")
proc sendExact*(s:Socket,buf:string) =
     var ilen:int=buf.len
     discard s.send(ilen.addr,sizeof(ilen))
     s.send(buf)
proc sendError*(s:Socket) =
     var ilen:int = -1
     discard s.send(ilen.addr,sizeof(ilen))
proc serverHandler*(p:ServerParam) {.thread.}  =
     var line:string=""
     var s=p[0]
     let dir=p[3]
     if p[2]:
        setVerboseLog()
     while true:
       s.readLine(line)
       line.stripLineEnd()
       if line == "":
           break
       let words=line.split(" ")
       let cmd=words[0]
       info "cmd: " & cmd
       #discard stdin.readLine()
       case cmd
       of "md5":
            let strj = $(%(p[1][]))
            sendExact(s,strj)
       of "download":
            info  "download"
            if len(words)<2:
                    s.sendError()
            else:
                    let dfilename=words[1]
                    if existsFile(dir.joinPath(dfilename)):
                       let fcontent = readFile(dir.joinPath(dfilename)) 
                       s.sendExact(fcontent)
                    else:
                        s.sendError()
       else:
           debug "unknow command received "& cmd 

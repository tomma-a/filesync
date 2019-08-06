import os, times, tables, md5, json, net, logging
export json, tables, net
type
    fileinfo* = tuple[md5: string, lastmt: times.Time]
    filetable* = TableRef[string, fileinfo]
    ServerParam* = (Socket, ptr filetable, bool, string)
    Umd5Param* = tuple[ori: ptr filetable, dir: string]
proc getMLM(path: string): fileinfo =
    result.md5 = $toMD5(readFile(path))
    result.lastmt = getLastModificationTime(path)
proc `%`*(f: fileinfo): JsonNode =
    result = newJObject()
    result.add("md5", newJString(f.md5))
    result.add("lastmt", newJint(f.lastmt.toUnix()))
proc setVerboseLog*() =
    var logger = newConsoleLogger(fmtStr = "[$datetime $appname $levelid]")
    addHandler(logger)
    setLogFilter(lvlAll)
proc newFiletable*(dir: string): filetable =
    result = newTable[string, fileinfo]()
    for path in walkDirRec(dir, relative = true):
        result.add(path, getMLM(dir.joinPath(path)))
proc updateLmd5*(info: Umd5Param) {.thread.} =
    while true:
        sleep(10000)
        let a = newFiletable(info.dir)
        info.ori[] = a
proc sendFiletable*(f: filetable, s: Socket) =
    let jsonstr = $(%f)
    s.send(jsonstr)

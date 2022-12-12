import os
import strformat
import strutils
import std/nre
import std/logging
import std/sugar
import std/sequtils

import std/parseopt

type Mode = enum Patch, Minor, Major

let consoleLogger = newConsoleLogger(Level.lvlInfo)
addHandler(consoleLogger)

proc getCurrentMode(): Mode =
  var p = initOptParser()
  var  mode = Mode.Patch
  while true:
    p.next()
    case p.kind
    of cmdEnd: break
    of cmdShortOption, cmdLongOption:
      if p.key == "major":
        mode = Mode.Major
      elif p.key == "minor":
        mode = Mode.Minor
      elif p.key == "patch":
        mode = Mode.Patch
      elif p.key == "version":
        const nimbleFile = staticRead "../update_nimble_version.nimble"
        let matchedLines = nimbleFile.split('\n').filter(line =>
          line.find(re"""version.*=.*"(?<text>).*""").isSome
        )
        if matchedLines.len > 0:
          let res = matchedLines[0].match(re"""version.*=.*"(?<text>.*)".*""")
          echo res.get.captures["text"]
          quit(0)
        else:
          fatal("version not found")
          quit(1)
      else:
        fatal(fmt"Unknown argument --{p.key}")
        quit(1)
    of cmdArgument:
      debug "Argument: ", p.key
  return mode

type MyTuple = (int,int,int)

proc updateTuple(val: var MyTuple, mode: Mode) =
  if mode == Mode.Patch:
    val = (val[0], val[1], val[2] + 1)
  elif mode == Mode.Minor:
    val = (val[0], val[1] + 1, 0)
  elif mode == Mode.Major:
    val = (val[0]+1, 0, 0)
  return

proc processFile(fileName: string, mode: Mode) =
  info fmt"File: {fileName}"
  let content = split(readFile(fileName), '\n')
  var newLines = newSeq[string]()
  for line in content:
    let res = line.find(re"""version.*=.*"(?<text>).*""")
    var newLine = line
    if res.isSome:
      let m= line.match(re"""version.*=.*"(?<a>.*)\.(?<b>.*)\.(?<c>.*)".*""")
      var val: MyTuple = (
        parseInt(m.get.captures["a"]),
        parseInt(m.get.captures["b"]),
        parseInt(m.get.captures["c"])
      )
      let strBefore = fmt"{val[0]}.{val[1]}.{val[2]}"
      info fmt"Detected version: {strBefore}"
      updateTuple(val, mode)
      let strAfter = fmt"{val[0]}.{val[1]}.{val[2]}"
      info fmt"Updated version: {strAfter}"
      newLine = line.replace(strBefore, strAfter)
    debug newLine
    newLines.add(newLine)
    writeFile(fileName, newLines.join("\n"))

when isMainModule:
  let mode = getCurrentMode()
  for file in walkFiles("*.nimble"):
    processFile(file, mode)

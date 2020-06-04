import strformat, strutils, os, random
from times import getTime, toUnix, nanosecond

type
    Markov* = object
        cache*: seq[seq[string]]
        cacheSize*: int

proc pure*(s:string):string=
    result = s.replace(".", "").replace(",", "").replace("?", "").replace("!", "").replace("'", "").replace(":", "").replace(";", "")
    
proc chain*(m: var Markov, words:seq[string]):seq[string] =
    var options:seq[seq[string]] = @[]
    for line in m.cache:
        if line[0].toLowerAscii() == words[words.len-1].toLowerAscii():
            options.add line
            
    randomize()
    if options.len > 0:
        return options[rand(0..options.len-1)]

    
proc generate*(m: var Markov, wordLimit:int = 10):string=
    let now = getTime()
    randomize(now.toUnix * 1000000000 + now.nanosecond)
    var f:seq[string] = m.cache.sample()
    
    for line in m.cache:
        var next = m.chain(f)
        if next.len == 0:
            break
        
        if f.len == 0:
            f.add next[0]
            
        for word in next[1..next.len-1]:
            f.add word
            
            if (word.endsWith(".") or word.endsWith("!") or word.endsWith("?")) and f.len > wordLimit:
                break
        
        if (f[f.len-1].endsWith(".") or f[f.len-1].endsWith("!") or f[f.len-1].endsWith("?")) and f.len > wordLimit:
            break
        
    result = f.join(" ")
proc feed*(m: var Markov, input:seq[string]) =
    var starti = 0
    var endi = m.cacheSize

    while (endi-1) < input.len:
        m.cache.add input[starti..endi-1]
        starti += 1
        endi += 1
           
proc feed*(m: var Markov, input:string) =
    m.feed(input.split(" "))

proc read*(m: var Markov, filepath:string) =
    if existsFile(filepath):
        for line in readFile(filepath).split("\n"):
            m.feed(line)

proc readDir*(m: var Markov, dirpath:string) =
    if existsDir(dirpath):
        for kind, path in walkDir(dirpath):
            m.read(path)
            
proc newMarkov*(cacheSize:int = 3):Markov =
    result.cacheSize = cacheSize
    
proc wordnet*(search:string) =
    let base:string = "http://wordnetweb.princeton.edu/perl/webwn?"
    let args:string = fmt"s={search}&sub=Search+WordNet&o2=&o0=1&o8=1&o1=1&o7=&o5=&o9=&o6=&o3=&o4=&h="
    let url:string = base&args

proc wiktionary*(search:string) =
    let url:string = "https://en.wiktionary.org/wiki/"&search

extra["firstLine"] = fun(s: String): String {
  return processTrimmed(s) {
    s.substring(0, s.indexOf("\n") + 1)
  }
}

extra["lastLine"] = fun(s: String): String {
  return processTrimmed(s) {
    s.substring(s.lastIndexOf("\n"))
  }
}

extra["withoutLastLine"] = fun(s: String): String {
  return processTrimmed(s) {
    it.substring(0, it.lastIndexOf("\n")) // TODO implement & test
  }
}

fun processTrimmed(s: String, f: (s: String) -> String): String {
  val startIndex = s.length - s.trimStart().length
  val endIndex   = s.trimEnd().length
  //println("pT: s.length = ${s.length}; startIndex = $startIndex; endIndex = $endIndex; s = '${s.substring(startIndex, endIndex)}' -> '${f(s.substring(startIndex, endIndex))}'")
  return "${s.substring(0, startIndex)}${f(s.substring(startIndex, endIndex))}${s.substring(endIndex)}"
}
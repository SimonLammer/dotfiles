extra["firstLine"] = fun(s: String): String {
  return processTrimmed(s) {
    unlessSingleLine(it) {
      it.substring(0, it.indexOf("\n"))
    }
  }
}

extra["lastLine"] = fun(s: String): String {
  return processTrimmedEnd(s) {
    it.substring(it.lastIndexOf("\n") + 1)
  }
}

extra["withoutLastLine"] = fun(s: String): String {
  return processTrimmed(s) {
    it.substring(0, Math.max(0, it.lastIndexOf("\n")))
  }
}

fun processTrimmed(s: String, f: (s: String) -> String): String {
  return processTrimmedStart(s) {
    processTrimmedEnd(it, f)
  }
}

fun processTrimmedStart(s: String, f: (s: String) -> String): String {
  val startIndex = s.length - s.trimStart().length
  return "${s.substring(0, startIndex)}${f(s.substring(startIndex))}"
}

fun processTrimmedEnd(s: String, f: (s: String) -> String): String {
  val endIndex = s.trimEnd().length
  return "${f(s.substring(0, endIndex))}${s.substring(endIndex)}"
}

fun unlessSingleLine(s: String, f: (s: String) -> String): String {
  return if (s.indexOf("\n") == -1) {
    s
  } else {
    f(s)
  }
}
extra["debug"] = fun(s: String): String {
  return s
}

extra["firstLine"] = fun(s: String): String {
  return if (s.indexOf("\n") == -1) {
    s
  } else {
    processTrimmed(s) {
      it.substring(0, it.indexOf("\n"))
    }
  }
}

extra["lastLine"] = fun(s: String): String {
  return processTrimmedEnd(s) {
    if (it.indexOf("\n") == -1) {
      it
    } else {
      it.substring(it.lastIndexOf("\n") + 1)
    }
  }
}

extra["withoutLastLine"] = fun(s: String): String {
  val value = processTrimmed(s) {
    it.substring(0, Math.max(0, it.lastIndexOf("\n")))
  }
  return if (value.trim().length == 0) {
    ""
  } else {
    value
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
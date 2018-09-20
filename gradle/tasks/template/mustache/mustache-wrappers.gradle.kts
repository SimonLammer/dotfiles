import java.util.function.Function

extra["mustache-wrappers"] = mapOf(
  "debug" to Function<String, String> { s ->
    println("MustacheWrapper debug: '$s'")
    s
  },

  "firstLine" to Function<String, String> { s ->
    if (s.indexOf("\n") == -1) {
      s
    } else {
      processTrimmed(s) {
        it.substring(0, it.indexOf("\n"))
      }
    }
  },

  "lastLine" to Function<String, String> { s ->
    processTrimmedEnd(s) {
      if (it.indexOf("\n") == -1) {
        it
      } else {
        it.substring(it.lastIndexOf("\n") + 1)
      }
    }
  },

  "withoutLastLine" to Function<String, String> { s ->
    val value = processTrimmed(s) {
      it.substring(0, Math.max(0, it.lastIndexOf("\n")))
    }
    if (value.trim().length == 0) {
      ""
    } else {
      value
    }
  }
)

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
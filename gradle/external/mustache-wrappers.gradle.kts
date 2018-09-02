extra["firstLine"] = fun(s: String): String {
  return s.substring(0, s.indexOf("\n") + 1)
}

extra["lastLine"] = fun(s: String): String {
  println("last")
  println("-->")
  println(s)
  println("<--")
  val res = s.substring(s.lastIndexOf("\n"))
  println("-->")
  println(res)
  println("<--")
  return res
}

extra["wshoutLastLine"] = fun(s: String): String {
  println("wshoutLast")
  println("-->")
  println(s)
  println("<--")
  val res = s.substring(0, s.lastIndexOf("\n")) // TODO implement & test
  println("-->")
  println(res)
  println("<--")
  return res
}
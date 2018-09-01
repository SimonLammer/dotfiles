import com.github.mustachejava.*
import java.io.*

plugins {}
repositories {}

buildscript {
  repositories {
    mavenCentral()
  }
  dependencies {
    classpath("com.github.spullara.mustache.java:compiler:0.9.5")
  }
}

tasks {
  val mustache by creating {
    val mf = DefaultMustacheFactory()
    val mustache = mf.compile(StringReader("Hello {{text}}"), "greeting")
    mustache.execute(PrintWriter(System.out), hashMapOf("text" to "world")).flush()
  }
}
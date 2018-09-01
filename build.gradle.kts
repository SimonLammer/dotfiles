import java.io.*
import com.github.mustachejava.*
import org.yaml.snakeyaml.*

plugins {}
repositories {}

buildscript {
  repositories {
    mavenCentral()
  }
  dependencies {
    classpath("com.github.spullara.mustache.java:compiler:+")
    classpath("org.yaml:snakeyaml:+")
  }
}

tasks {
  val mustache by creating {
    doLast {
      val yaml = Yaml().load(FileInputStream(File("mustache-data.yml")))
      val map = mapOf(
        "foo" to "bar",
        "num" to 4,
        "first" to java.util.function.Function<String, String> { it.substring(0, it.indexOf("\n") + 1) },
        "last" to java.util.function.Function<String, String> { it.substring(it.indexOf("\n")) }
      )
      val data = listOf(yaml, map)
      val mf = DefaultMustacheFactory()
      val mustache = mf.compile("template.mustache")
      mustache.execute(PrintWriter(System.out), data).flush()
    }
  }

  create("foo") {
    doLast {
      println("bar")
    }
  }
}
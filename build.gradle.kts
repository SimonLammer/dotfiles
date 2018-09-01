import java.util.function.Function
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

val MUSTACHE_DATA_FILENAME = extra["mustacheDataFilename"] as String

val YAML = Yaml()
val MUSTACHE = "mustache"
val MUSTACHE_EXT = MUSTACHE
val MUSTACHE_FACTORY = DefaultMustacheFactory()
val MUSTACHE_WRAPPERS = mapOf<Any, Any>(
  "first" to Function<String, String> {
    it.substring(0, it.indexOf("\n") + 1)
  },
  "last" to Function<String, String> {
    it.substring(it.indexOf("\n"))
  }
)

tasks {
  val mustache by creating {
    doLast {
      val yaml = YAML.load(FileInputStream(File(MUSTACHE_DATA_FILENAME)))
      val mf = DefaultMustacheFactory()
      val mustache = mf.compile("template.mustache")
      mustache.execute(
        PrintWriter(System.out),
        listOf(yaml, MUSTACHE_WRAPPERS)
      ).flush()
    }
  }
}

File(".").walkTopDown().forEach { file ->
  if(file.isFile() && file.name.endsWith(".$MUSTACHE_EXT")) {
    println(file)

    val task = tasks.create("$MUSTACHE'${file.path.substring(2).replace("/", ",")}") {
      group = "$MUSTACHE"
      doLast {
        println(file)
        val data = mutableListOf()
        var dir = file.parentFile
        while (dir != null) {
          dir.listFiles(FilenameFilter { dir: File, name: String ->
            name == MUSTACHE_DATA_FILENAME
          }).forEach {
            val yaml = YAML.load(FileInputStream(it))
            data.add(yaml)
          }
          dir = dir.parentFile
        }
        data.add(MUSTACHE_WRAPPERS)
        data.reverse()
        println(data)
        val mustache = MUSTACHE_FACTORY.compile(FileReader(file), file.name)
        mustache.execute(PrintWriter(System.out), data).flush()
        println()
      }
    }

    tasks.named("mustache").configure {
      dependsOn(task)
    }
  }
}
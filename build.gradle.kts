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

File(".").walkTopDown().forEach { input ->
  if(input.isFile() && input.name.endsWith(".$MUSTACHE_EXT")) {
    val output = File(input.parent, input.name.substring(0, input.name.length - MUSTACHE_EXT.length - 1))
    val taskName = "$MUSTACHE#${input.path.substring(2).replace("/", ",")}"
    logger.lifecycle("Creating mustache task for ${input.path} (\"$taskName\")")
    val task = tasks.create(taskName) {
      group = "$MUSTACHE"
      inputs.file(input)
      outputs.file(output)
      doLast {
        logger.lifecycle("Preparing for parsing of ${input.path} to ${output.path}")
        val data = mutableListOf()
        var dir = input.parentFile
        while (dir != null) {
          dir.listFiles(FilenameFilter { dir: File, name: String ->
            name == MUSTACHE_DATA_FILENAME
          }).forEach {
            val yaml = YAML.load(FileInputStream(it))
            data.add(yaml)
            logger.info("Adding data souce ${it.path}")
          }
          dir = dir.parentFile
        }
        data.add(MUSTACHE_WRAPPERS)
        data.reverse()
        logger.info("Parsing with $data")
        val mustache = MUSTACHE_FACTORY.compile(StringReader("{{> ${input.path}}}"), input.name)
        mustache.execute(PrintWriter(System.out), data).flush()
        println()
      }
    }

    tasks.named("mustache").configure {
      dependsOn(task)
    }
  }
}
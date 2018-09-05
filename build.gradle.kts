import java.util.function.Function
import java.util.Collections
import java.nio.charset.*
import java.nio.file.Files
import java.io.*
import com.github.mustachejava.*
import com.github.mustachejava.reflect.*
import com.github.mustachejava.util.*
import org.yaml.snakeyaml.*
import com.github.ricksbrown.cowsay.Cowsay

plugins {}
repositories {}

buildscript {
  repositories {
    mavenCentral()
  }
  dependencies {
    classpath("com.github.spullara.mustache.java:compiler:+")
    classpath("org.yaml:snakeyaml:+")
    classpath("com.github.ricksbrown:cowsay:+")
  }
}

val MUSTACHE_WRAPPERS_GRADLE = File("gradle/external/mustache-wrappers.gradle.kts")
val DATA_TRANSFORMERS_GRADLE = File("gradle/external/data-transformers.gradle.kts")

apply {
  listOf(MUSTACHE_WRAPPERS_GRADLE, DATA_TRANSFORMERS_GRADLE).forEach {
    from(it.path)
  }
}

val MUSTACHE_DATA_FILENAME          = extra["mustacheDataFilename"]  as String
val MUSTACHE_DATA_FILE_CONCATINATOR = extra["mustacheDataFileConcatinator"] as String
val MUSTACHE_EXT                    = extra["mustacheExt"]           as String
val MUSTACHE_PARTIAL_EXT            = extra["mustachePartialExt"]    as String
val MUSTACHE_PARTIAL_PREFIX         = extra["mustachePartialPrefix"] as String
val MUSTACHE_PARTIAL_SUFFIX         = extra["mustachePartialSuffix"] as String

val transformData = extra["transform-data"] as (Iterable<Any>) -> Iterable<Any>

val GRADLE_PROPERTIES = File("gradle.properties")

val YAML = Yaml()
val MUSTACHE = "mustache"
val MUSTACHE_FACTORY = DefaultMustacheFactory()
MUSTACHE_FACTORY.objectHandler = object : ReflectionObjectHandler() {
  override fun find(name: String, scopes: List<Any?>): com.github.mustachejava.util.Wrapper {
    val wrapper = super.find(name, scopes)
    if (wrapper is MissingWrapper) {
      throw RuntimeException("Mustache variable '$name' not in scope!")
    }
    return wrapper
  }
}
val MUSTACHE_WRAPPERS = listOf( // will be mapped to mapOf<String, Any>
  "debug",
  "firstLine",
  "lastLine",
  "withoutLastLine"
).map {
  val f = extra[it] as (s: String) -> String
  it to Function<String, String> {
    f(it)
  }
}.toMap<String, Any>()

tasks {
  val dotfilesGroup = "Dotfiles"

  val mustacheTest = tasks.create("mustacheTest") {
    group = dotfilesGroup
    
    doLast {
      println(Cowsay.think(arrayOf("-f", "ghostbusters", "tested tests tested")))
    }
  }

  tasks.create("mustache") {
    group = dotfilesGroup
    dependsOn(mustacheTest)
    
    doLast {
      println(Cowsay.say(arrayOf("-f", "stegosaurus", "I've successfully rendered all of your mustache templates.")))
    }
  }
}

File(".").walkTopDown().forEach { input ->
  if (input.isFile() && input.name.endsWith(".$MUSTACHE_EXT") && !input.name.endsWith(".$MUSTACHE_PARTIAL_EXT")) {
    val output = File(input.parent, "${input.name.substring(0, input.name.length - MUSTACHE_EXT.length - 1)}")
    val taskName = "$MUSTACHE#${input.path.substring(2).replace("/", ",")}"
    logger.lifecycle("Creating mustache task for ${input.path} (\"$taskName\")")

    val task = tasks.create(taskName) {
      group = "$MUSTACHE"
      val inputsFiles = mutableListOf(GRADLE_PROPERTIES, MUSTACHE_WRAPPERS_GRADLE, DATA_TRANSFORMERS_GRADLE, input)
      val mustacheDataFiles = fetchMustacheDataFiles(input.parentFile)
      inputsFiles.addAll(mustacheDataFiles)
      inputs.files(inputsFiles)
      outputs.file(output)

      if (!isTestMustacheFile(input)) {
        mustRunAfter(tasks.named("${MUSTACHE}Test"))
      }

      doLast {
        logger.lifecycle("Preparing for parsing of ${input.path} to ${output.path}")
        val dataInputStreams = mustacheDataFiles.map {
          logger.info("Adding data source ${it.path}")
          FileInputStream(it)
        }
        logger.lifecycle("Loading data")
        val data = mutableListOf<Any>(MUSTACHE_WRAPPERS)
        data.addAll(
          transformData (
            YAML.loadAll(
              concatMustacheInputStreams(
                dataInputStreams
              )
            )
          )
        )
        logger.info("Data: $data")
        logger.lifecycle("Parsing")
        val mustache = MUSTACHE_FACTORY.compile(StringReader("$MUSTACHE_PARTIAL_PREFIX${input.path}$MUSTACHE_PARTIAL_SUFFIX"), input.name)
        mustache.execute(FileWriter(output), data).flush()
      }
    }

    tasks.named("mustache").configure {
      dependsOn(task)
    }

    if (isTestMustacheFile(input)) {
      val testTask = tasks.create("mustacheTest${taskName.substring(taskName.indexOf('#'))}") {
        group = "${MUSTACHE}Test"
        dependsOn(task)
        val expectationFile = File(input.parent, "${input.name.substring(0, input.name.length - MUSTACHE_EXT.length - 1)}.expected")
        val inputsFiles = mutableListOf(expectationFile)
        inputsFiles.addAll(task.inputs.files.files)
        inputs.files(inputsFiles)
        outputs.files(listOf())

        doLast {
          logger.lifecycle("Asserting that '${output.path}' and '${expectationFile.path}' are equal in content")
          val expected = BufferedReader(FileReader(expectationFile))
          val actual   = BufferedReader(FileReader(output))

          fun throwGradleException(s: String) {
            expected.close()
            actual.close()
            throw GradleException(s)
          }

          var lineNumber = 0
          while (true) {
            lineNumber++
            val expectedLine = expected.readLine()
            val actualLine   = actual.readLine()

            if ((expectedLine == null) != (actualLine == null)) {
              throwGradleException("Number of lines doesn't match!")
            }
            if (expectedLine == null || actualLine == null) {
              break
            }
            if (!actualLine.equals(expectedLine)) {
              throwGradleException("Line ${lineNumber} doesn't match!\n\texpected: '$expectedLine'\n\t     got: '$actualLine'")
            }
          }
        }
      }
      tasks.named("mustacheTest").configure {
        dependsOn(testTask)
      }
    }
  }
}

fun isTestMustacheFile(file: File): Boolean = file.path.startsWith("./gradle/external/tests")

fun fetchMustacheDataFiles(_dir: File?) :List<File> {
  var dir = _dir
  var files = mutableListOf<File>()
  while (dir != null) {
    files.addAll(
      dir.listFiles(FilenameFilter { _, name: String ->
        name == MUSTACHE_DATA_FILENAME
      })
    )
    dir = dir.parentFile
  }
  Collections.reverse(files)
  return files
}

fun concatInputStreams(streams: Iterable<InputStream>, concatinatorFactory: () -> InputStream) :InputStream {
  val iterator = streams.iterator()
  return if (!iterator.hasNext()) {
    ByteArrayInputStream(byteArrayOf())
  } else {
    var concatinatedInputStreams = mutableListOf(iterator.next())
    while (iterator.hasNext()) {
      concatinatedInputStreams.add(concatinatorFactory())
      concatinatedInputStreams.add(iterator.next())
    }
    SequenceInputStream(Collections.enumeration(concatinatedInputStreams))
  }
}

fun mustacheFileConcatinatorInputStream(): InputStream {
  val concatinatorByteArray = MUSTACHE_DATA_FILE_CONCATINATOR.toByteArray(Charsets.UTF_8)
  return ByteArrayInputStream(concatinatorByteArray)
}

fun concatMustacheInputStreams(streams: Iterable<InputStream>) =
  concatInputStreams(streams, { mustacheFileConcatinatorInputStream() })
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

/* TODO: refactor
Workflow:
  template files -> template file render tasks             (once for tests; once for data - dependsOn tests)
    find template data files
    render templated template data files                   (this dependsOn seperate task)
    provide template data file content streams             (cache? when filesize...)
    concat template data file content streams
    interpret concatinated template data -> template data
    transform template data
    render template
*/

val templateFileExtension:        String by project
val templateDataFileName:         String by project
val templateDataFileConcatinator: String by project
val templateRenderTestDirectory = File(extra["templateRenderTestDirectory"] as String)
check(templateRenderTestDirectory.isDirectory())

val helperFiles = File("gradle/tasks/template/mustache").listFiles { f: File -> f.isFile() && f.name.endsWith(".gradle.kts") }
apply {
  helperFiles.forEach {
    from(it)
  }
}
val mustacheWrappers = (extra["mustache-wrappers"] as Map<String, Function<String, String>>)
val transformData    = extra["transform-data"]    as (Iterable<Any>) -> Iterable<Any>
helperFiles.forEach { logger.info("Loaded helper file $it") }
logger.info("Available mustache wrappers: ${mustacheWrappers.keys.joinToString()}")

val testTasks = createTemplateRenderingTasks(templateRenderTestDirectory)
val testCleanTask = tasks.create("renderTemplatesTestClean") {
  doLast{
    templateRenderTestDirectory
      .walkTopDown()
      .filter { it.isFile() && File(it.parentFile, it.name + templateFileExtension).isFile() }
      .forEach {
        it.delete()
        logger.info("Deleted $it")
      }
  }
}
testTasks.forEach { it.configure { it.dependsOn(testCleanTask) } }
val testTask = tasks.create("renderTemplatesTest") {
  inputs.files(templateRenderTestDirectory)
  outputs.files(listOf())
  dependsOn(testTasks)
  doLast {
    templateRenderTestDirectory
      .walkTopDown()
      .filter { isTemplateFile(it) }
      .forEach { file ->
        val renderedFile    = File(file.parentFile, file.name.substring(0, file.name.length - templateFileExtension.length))
        val expectationFile = File(file.parentFile, renderedFile.name + ".expected")
        logger.info("Asserting that '${renderedFile.path}' and '${expectationFile.path}' are equal in content")
        assertFileContentIsEqual(renderedFile, expectationFile)
      }
    println(Cowsay.say(arrayOf("-f", "default", "Mustache template rendering tests have succeeded.")))
  }
}
tasks.named("test").configure { dependsOn(testTask) }
val renderTask = tasks.create("renderTemplates") {
  inputs.files(File("data"))
  outputs.files(listOf())
  dependsOn(createTemplateRenderingTasks(File("data")))
  shouldRunAfter("test")
  doLast {
    println(Cowsay.say(arrayOf("-f", "default", "I've successfully rendered all of your mustache templates.")))
  }
}
tasks.named("run").configure { dependsOn(renderTask) }

val yaml = Yaml()
val mustacheFactory = DefaultMustacheFactory(File("."))
mustacheFactory.objectHandler = object : ReflectionObjectHandler() {
  override fun find(name: String, scopes: List<Any?>): com.github.mustachejava.util.Wrapper {
    val wrapper = super.find(name, scopes)
    if (wrapper is MissingWrapper) {
      throw RuntimeException("Mustache variable '$name' not in scope!\n\tscopes: $scopes")
    }
    return wrapper
  }
}

fun assertFileContentIsEqual(a: File, e: File) {
  val actual   = BufferedReader(FileReader(a))
  val expected = BufferedReader(FileReader(e))

  fun throwGradleException(s: String) {
    actual.close()
    expected.close()
    throw GradleException(s)
  }

  var lineNumber = 0
  while (true) {
    lineNumber++
    val actualLine   = actual.readLine()
    val expectedLine = expected.readLine()

    if ((expectedLine == null) != (actualLine == null)) {
      throwGradleException("Number of lines doesn't match!")
    }
    if (expectedLine == null || actualLine == null) {
      break
    }
    if (!actualLine.equals(expectedLine)) {
      throwGradleException("Line ${lineNumber} of $a doesn't match expectation!\n\texpected: '$expectedLine'\n\t     got: '$actualLine'")
    }
  }
}

fun createTemplateRenderingTasks(dir: File): Iterable<Task> {
  require(dir.isDirectory())
  return dir
    .walkTopDown()
    .filter { isTemplateFile(it) }
    .map { createTemplateRenderingTask(it) }
    .toList()
}

fun isTemplateFile(file: File) = file.isFile() && file.name.endsWith(templateFileExtension)

fun createTemplateRenderingTask(file: File): Task {
  val (dataFiles, templateDataFileRenderingTaskNames) = fetchTemplateDataFiles(file)
  val output = File(file.parentFile, file.name.substring(0, file.name.length - templateFileExtension.length))
  logger.info("Creating template rendering task for $file")
  return tasks.create(templateRenderingTaskName(file)) {
    inputs.files(helperFiles)
    inputs.files(dataFiles)
    outputs.file(output)
    shouldRunAfter("test")

    if (templateDataFileRenderingTaskNames.size > 0) {
      logger.info("DependsOn:")
    }
    templateDataFileRenderingTaskNames.forEach {
      logger.info("\t$it")
      dependsOn(it)
      mustRunAfter(it)
    }
    
    logger.info("DataFiles:")
    dataFiles.forEach { logger.info("\t$it") }

    doLast {
      logger.info("Rendering $file to $output")
      val data = mutableListOf<Any>(mustacheWrappers)
      data.addAll(
        transformData (
          yaml.loadAll(
            concatTemplateDataFileInputStreams(
              dataFiles.map { FileInputStream(it) }
            )
          )
        )
      )
      logger.info("Data: $data")
      val mustache = mustacheFactory.compile(InputStreamReader(FileInputStream(file), Charsets.UTF_8), file.absolutePath)
      mustache.execute(FileWriter(output), data).flush()
    }
  }
}

fun fetchTemplateDataFiles(file: File): Pair<List<File>, List<String>> {
  val dataFiles = mutableListOf<File>()
  val templateDataFileRenderingTaskNames = mutableListOf<String>()

  var dir: File? = file.parentFile
  while(dir != null) {
    val dataFile         = File(dir, templateDataFileName)
    val dataFileTemplate = File(dir, templateDataFileName + templateFileExtension)
    
    if (dataFileTemplate.isFile()) {
      if (!dataFileTemplate.equals(file)) {
        templateDataFileRenderingTaskNames.add(templateRenderingTaskName(dataFileTemplate))
        dataFiles.add(dataFile)
      }
    } else if (dataFile.isFile()) {
      dataFiles.add(dataFile)
    }

    dir = dir.parentFile
  }

  Collections.reverse(dataFiles)
  return Pair(dataFiles, templateDataFileRenderingTaskNames)
}

fun templateRenderingTaskName(file: File) = "renderTemplate#${file.path.replace("/", ",")}"

fun concatTemplateDataFileInputStreams(streams: Iterable<InputStream>) :InputStream {
  val concatinatorByteArray = templateDataFileConcatinator.toByteArray(Charsets.UTF_8)
  val iterator = streams.iterator()
  return if (!iterator.hasNext()) {
    ByteArrayInputStream(byteArrayOf())
  } else {
    var concatinatedInputStreams = mutableListOf(iterator.next())
    while (iterator.hasNext()) {
      concatinatedInputStreams.add(ByteArrayInputStream(concatinatorByteArray))
      concatinatedInputStreams.add(iterator.next())
    }
    SequenceInputStream(Collections.enumeration(concatinatedInputStreams))
  }
}

// ---------------------------------------------------------------------------------------------

open class TemplateRenderer : DefaultTask() {
  lateinit var file: File

  @TaskAction
  fun renderTemplates() {
    require(file.isFile()) { "TemplateRenderer.file must be a file!\n\tfile: $file"}
    println("Hello $file")
  }
}

val a = tasks.create<TemplateRenderer>("debug") {
  file = File("Readme.md")
  dependsOn(listOf())
}

fun r(n: Int): Task {
  return tasks.create("r$n") {
    if (n > 1) {
      dependsOn(r(n-1))
    }
    doLast {
      println("$n")
    }
  }
}
r(3)

//apply {
  //  listOf(MUSTACHE_WRAPPERS_GRADLE, DATA_TRANSFORMERS_GRADLE).forEach {
    //    from(it.path)
  //  }
//}

/*
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
  val dotfilesGroup = "Mustache"

  val mustacheTest = tasks.create("mustacheTest") {
    group = dotfilesGroup

    listOf( // clean before tests
      File("gradle/external/tests/yaml-templates/after/mustache.yml"),
      File("gradle/external/tests/yaml-templates/before/mustache.yml")
    ).forEach {
      if (it.exists()) {
        it.delete()
      }
    }

    doLast {

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
    val taskName = mustacheTaskName(input)
    logger.info("Creating mustache task for ${input.path} (\"$taskName\")")

    val task = tasks.create(taskName) {
      group = "$MUSTACHE"
      val inputsFiles = mutableListOf(GRADLE_PROPERTIES, MUSTACHE_WRAPPERS_GRADLE, DATA_TRANSFORMERS_GRADLE, input)
      val mustacheDataFiles = fetchMustacheDataFiles(input)
      inputsFiles.addAll(mustacheDataFiles)
      inputs.files(inputsFiles)
      outputs.file(output)

      // depend on mustache data files generated by mustache
      mustacheDataFiles.forEach { file ->
        val f = File(file.parentFile, "${file.name}.$MUSTACHE_EXT")
        if (!input.equals(f) && f.exists()) {
          dependsOn(mustacheTaskName(f))
        }
      }

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

fun mustacheTaskName(file: File): String = "$MUSTACHE#${file.path.substring(2).replace("/", ",")}"

fun isTestMustacheFile(file: File): Boolean = file.path.startsWith("./gradle/external/tests")

fun fetchMustacheDataFiles(file: File): List<File> {
  var dir: File? = file.parentFile
  var files = mutableListOf<File>()
  while (dir != null) {
    val dataFile = File(dir, MUSTACHE_DATA_FILENAME)
    val dataFileTemplate = File(dir, "$MUSTACHE_DATA_FILENAME.$MUSTACHE_EXT")
    if (!file.equals(dataFileTemplate) && (dataFileTemplate.exists() || dataFile.exists())) {
      files.add(dataFile)
    }

    dir = dir?.parentFile
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
*/
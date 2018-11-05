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
  dependsOn(createTemplateRenderingTasks(File("data"), verbose=true))
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

fun createTemplateRenderingTasks(dir: File, verbose: Boolean = false): Iterable<Task> {
  require(dir.isDirectory())
  return dir
    .walkTopDown()
    .filter { isTemplateFile(it) }
    .map { createTemplateRenderingTask(it, verbose) }
    .toList()
}

fun isTemplateFile(file: File) = file.isFile() && file.name.endsWith(templateFileExtension)

fun createTemplateRenderingTask(file: File, verbose: Boolean = false): Task {
  val (dataFiles, templateDataFileRenderingTaskNames) = fetchTemplateDataFiles(file)
  val output = File(file.parentFile, file.name.substring(0, file.name.length - templateFileExtension.length))
  logger.info("Creating template rendering task for $file")
  return tasks.create(templateRenderingTaskName(file)) {
    inputs.files(helperFiles)
    inputs.files(dataFiles)
    inputs.files(listOf(file))
    outputs.file(output)
    shouldRunAfter("test")

    if (templateDataFileRenderingTaskNames.size > 0) {
      logger.info("\tDependsOn:")
    }
    templateDataFileRenderingTaskNames.forEach {
      logger.info("\t\t$it")
      dependsOn(it)
      mustRunAfter(it)
    }
    
    logger.info("\tDataFiles:")
    dataFiles.forEach { logger.info("\t\t$it") }

    doLast {
      if (verbose) {
        logger.lifecycle("Rendering $file to $output")
      } else {
        logger.info("Rendering $file to $output")
      }
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
      logger.debug("Data: $data")
      val mustache = mustacheFactory.compile(InputStreamReader(FileInputStream(file), Charsets.UTF_8), file.absolutePath)
      val fw = FileWriter(output)
      mustache.execute(fw, data).flush()
      fw.close()
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

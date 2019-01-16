import java.util.function.Function
import java.util.*
import java.nio.charset.*
import java.nio.file.Files
import java.io.*
import org.yaml.snakeyaml.*
import com.github.ricksbrown.cowsay.Cowsay

buildscript {
  repositories {
    mavenCentral()
  }
  dependencies {
    classpath("org.yaml:snakeyaml:+")
    classpath("com.github.ricksbrown:cowsay:+")
  }
}

val yaml = Yaml()

tasks {
  val testTask = create("test-actions") {
    val tasks = createActionsTasks(File("gradle/tests/action"))
    dependsOn(tasks)
    mustRunAfter(tasks)

    doLast {
      logger.lifecycle("Run actions tests")
    }
  }

  tasks.named("test").configure{ dependsOn(testTask) }
}

fun findActionsFiles(dir: File): List<File> {
  // TODO: implement
  return listOf(File("gradle/tests/action/actions.yml"))
}

fun createActionsTasks(dir: File, taskNamePrefix: String = "actions"): Iterable<Task> {
  logger.lifecycle("Creating tasks actions under $dir") // TODO: logger.debug
  return findActionsFiles(dir).flatMap {
    val taskNameMiddle = it.parentFile
      .toRelativeString(dir)
      .replace("/", "-")
    val yamlData = yaml.load(FileInputStream(it)) as Map<*, *>
    logger.lifecycle("\t$it") // TODO: logger.debug

    return yamlData.map { (key, value) ->
      lateinit var taskNameSuffix : String
      lateinit var args : Map<String, *>
      if (key is Map<*,*>) {
        val entry = key.entries.single()
        taskNameSuffix = entry.key as String
        args = entry.value as Map<String, *>
      } else if (key is String) {
        taskNameSuffix = key
        args = mapOf()
      }

      tasks.create("$taskNamePrefix-$taskNameMiddle-$taskNameSuffix") {
        logger.lifecycle("\t\t$taskNameSuffix [$args]: $value") // TODO: logger.debug

        inputs.file(it)

        doLast {
          println("test")
        }
      }

    }.toList()
  }.toList()
}

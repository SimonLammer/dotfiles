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
  val testTask = create("actionsTest") {
    val tasks = createActionsTasks(File("gradle/tests/action"), "actionsTest")
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
  logger.info("Creating tasks actions under $dir")
  return findActionsFiles(dir).flatMap {
    val taskNameMiddle = it.parentFile
      .toRelativeString(dir)
      .replace("/", "-")
    val yamlData = yaml.load(FileInputStream(it)) as Map<*, *>
    logger.info("\t$it")

    return yamlData.map { (key, raw_actions) ->
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
      lateinit var actions : Iterable<Map<*, *>>
      if (raw_actions is Iterable<*>) {
        actions = raw_actions as Iterable<Map<*, *>>
      } else if (raw_actions is Map<*, *>) {
        actions = listOf(raw_actions)
      }

      logger.info("\t\t$taskNameSuffix")

      val enabled = args.get("enabled") // TODO: extract "enabled"?
      if (enabled == null || enabled == true) {
        createActionsTask(it, "$taskNamePrefix-$taskNameMiddle-$taskNameSuffix", args, actions)
      } else {
        null
      }
    }.toList().filterNotNull()
  }.toList()
}

fun createActionsTask(file: File, taskName: String, args: Map<String, *>, actions: Iterable<Map<*, *>>): Task {
  return tasks.create(taskName) {
    inputs.file(file)

    doLast {
      println("$taskName: $actions")
    }
  }
}

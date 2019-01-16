import java.util.function.Consumer
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

val commands = mutableMapOf<String, (File, Map<String, *>) -> Unit>()
extra["action-commands"] = commands
val helperFiles = File("gradle/tasks/action/commands").listFiles { f: File -> f.isFile() && f.name.endsWith(".gradle.kts") }
apply {
  helperFiles.forEach {
    from(it)
  }
}
logger.info("Available action commands: $commands")
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
  return findActionsFiles(dir).flatMap { file ->
    val taskNameMiddle = file.parentFile
      .toRelativeString(dir)
      .replace("/", "-")
    val yamlData = yaml.load(FileInputStream(file)) as Map<*, *>
    logger.info("\t$file")

    return yamlData.map { (key, raw_actions) ->
      lateinit var actionCommand : String
      lateinit var args : Map<String, *>
      if (key is Map<*,*>) {
        val entry = key.entries.single()
        actionCommand = entry.key as String
        args = entry.value as Map<String, *>
      } else if (key is String) {
        actionCommand = key
        args = mapOf()
      }
      lateinit var actions : Iterable<Map<String, *>>
      if (raw_actions is Iterable<*>) {
        actions = raw_actions as Iterable<Map<String, *>>
      } else if (raw_actions is Map<*, *>) {
        actions = listOf(raw_actions as Map<String, *>)
      }

      logger.info("\t\t$actionCommand")

      val enabled = args.get("enabled") // TODO: extract "enabled"?
      if (enabled == null || enabled == true) {
        tasks.create("$taskNamePrefix-$taskNameMiddle-$actionCommand") {
          inputs.file(file)

          doLast {
            actions.forEach {
              val command = commands.get(actionCommand)
              if (command == null) {
                throw RuntimeException("Unknown action '$actionCommand' in '$file'.")
              }
              command(file, it)
            }
          }
        }
      } else {
        logger.info("\t\t\tThis task is not enabled.")
        null
      }
    }.toList().filterNotNull()
  }.toList()
}

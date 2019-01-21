import java.util.function.Consumer
import java.util.*
import java.nio.charset.*
import java.nio.file.Files
import java.nio.file.Paths
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

val commands = mutableMapOf<String, (File, Map<String, *>, Boolean) -> Unit>()
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
  val testTasks = createActionsTasks(File("gradle/tests/action"), "actionsTest", false)
  val testTask = create("actionsTest") {
    dependsOn(testTasks)
    mustRunAfter(testTasks)

    doLast {
      println(Cowsay.say(arrayOf("-f", "default", "Actions tests have succeeded.")))
    }
  }

  val realTasks = createActionsTasks(File("data"), "actions", true)
  realTasks.forEach {
    it.dependsOn(testTask)
    it.group = "Actions"
  }

  tasks.named("test").configure{ dependsOn(testTask) }

  fun createActionsTestCleanTask(taskNameSuffix: String): Task {
    return create("actionsTestClean$taskNameSuffix") {
      doLast {
        logger.info("Cleaning links")
        listOf(
          "simple.txt",
          "hard.txt",
          "home.md",
          "override.txt",
          "relative-link.txt",
          "relative-existing.txt",
          "relative/relative-link.txt",
          "relative/relative-existing.txt"
        ).forEach {
          val file = File("gradle/tests/action/link/$it")
          if (!file.isDirectory()) {
            Files.deleteIfExists(file.toPath())
          }
        }
      }
    }
  }

  val cleanTask = createActionsTestCleanTask("")
  testTask.dependsOn(cleanTask)
  testTasks.forEach { it.dependsOn(cleanTask) }
  val postRunCleanTask = createActionsTestCleanTask("PostRun") 
  testTask.finalizedBy(postRunCleanTask)
  postRunCleanTask.dependsOn(create("actionsTestAssert") {
    doLast {
      fun assertLinks(list: Iterable<String>, file: File) {
        list.forEach {
          val link = File("gradle/tests/action/link/$it")
          check(
            !(link.isAbsolute()
              && Files.readSymbolicLink(
                link.toPath()
              ).toString().contains("..")
            ),
            { "The link of '$it' contains '..'!" }
          )
          check(
            Files.isSameFile(
              link.toPath(),
              file.toPath()
            ),
            { "'$link' does not link to '$file'" }
          )
        }
      }
      assertLinks(listOf(
        "simple.txt",
        "override.txt",
        "relative/relative-existing.txt",
        "relative/relative-link.txt"
      ), File("gradle/tests/action/link/resource.txt"))
      assertLinks(listOf(
        "relative-existing.txt",
        "relative-link.txt"
      ), File("gradle/tests/action/link/relative/resource.txt"))
      assertLinks(listOf("home.md"), File("Readme.md"))
      check(
        Files.readAllLines(Paths.get("gradle/tests/action/link/resource.txt"))
          .equals(Files.readAllLines(Paths.get("gradle/tests/action/link/hard.txt"))),
        { "Hard linking failed" }
      )
    }
  })
}

fun findActionsFiles(dir: File): List<File> {
  return dir
    .walkTopDown()
    .filter { it.name == "actions.yml" }
    .toList()
}

fun createActionsTasks(dir: File, taskNamePrefix: String = "actions", verbose: Boolean): Iterable<Task> {
  logger.info("Creating action tasks under $dir")
  return findActionsFiles(dir).flatMap { file ->
    val taskNameMiddle = file.parentFile
      .toRelativeString(dir)
      .replace("/", "-")
    val yamlData = yaml.load(FileInputStream(file)) as Map<*, *>
    logger.info("\t$file")

    yamlData.map { (key, raw_actions) ->
      lateinit var actionName : String
      lateinit var args : Map<String, *>
      if (key is Map<*,*>) {
        val entry = key.entries.single()
        actionName = entry.key as String
        args = entry.value as Map<String, *>
      } else if (key is String) {
        actionName = key
        args = mapOf()
      }
      lateinit var actions : Iterable<Map<String, *>>
      if (raw_actions is Iterable<*>) {
        actions = raw_actions as Iterable<Map<String, *>>
      } else if (raw_actions is Map<*, *>) {
        actions = listOf(raw_actions as Map<String, *>)
      }

      logger.info("\t\t$actionName")

      val enabled = args.get("enabled") // TODO: extract "enabled"?
      if (enabled == null || enabled == true) {
        tasks.create("$taskNamePrefix-$taskNameMiddle-$actionName") {
          inputs.file(file)

          doLast {
            actions.forEach {
              val commandName = it.get("action")
              if (commandName == null) {
                throw RuntimeException("Unknown command in action '$actionName' in '$file'.")
              }
              val command = commands.get(commandName)
              if (command == null) {
                throw RuntimeException("Unknown command '$command' in action '$actionName' in '$file'.")
              }
              command(file, it, verbose)
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

import com.github.ricksbrown.cowsay.Cowsay

buildscript {
  repositories {
    mavenCentral()
  }
  dependencies {
    classpath("com.github.ricksbrown:cowsay:+")
  }
}

tasks {
  val dotfilesGroup = "Dotfiles"

  val testTask = create("test") {
    group = dotfilesGroup

    doLast {
      println(Cowsay.think(arrayOf("-f", "ghostbusters", "All tests succeeded")))
    }
  }

  create("run") {
    group = dotfilesGroup
    dependsOn(testTask)

    doLast {
      println(Cowsay.say(arrayOf("-f", "stegosaurus", "Done")))
    }
  }
}

defaultTasks("run")

apply {
  fun loadIfGradleFile(file: File) {
    if (file.isFile() && file.name.endsWith(".gradle.kts")) {
      logger.info("Loading gradle file '${file.path}'")
      from(file)
    }
  }

  File("gradle/tasks").listFiles().forEach {
    if (it.isDirectory()) {
      it.listFiles().forEach {
        loadIfGradleFile(it)
      }
    } else {
      loadIfGradleFile(it)
    }
  }
}

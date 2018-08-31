import org.ajoberstar.grgit.Grgit

plugins {
  id("org.ajoberstar.grgit") version "3.0.0-beta.1" // http://ajoberstar.org/grgit/grgit-reference.html
}

repositories {
  jcenter()
}

tasks {
  val foo by creating {
    println("Hello World!")
  }
  
  val gitls by creating {
    val repo = Grgit.open()
    println(repo.head().author.name)
  }
}
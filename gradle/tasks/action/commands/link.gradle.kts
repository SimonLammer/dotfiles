import java.util.*
import java.util.function.Consumer
import java.nio.file.Files

/*
Description: Create file link
Arguments:
  Mandatory:
    "existing" [String] - The existing file
    "link"     [String] - The link name
  Optional:
    "symbolic" [Boolean] - Whether a symbolic link should be created, default: true
    "override" [Boolean] - Overwrite "link" file if such a symlink already exists, default: false
 */

(extra["action-commands"] as MutableMap<String,Any?>).put("link", fun(file: File, args: Map<String, *>) {
  val relativeLink = File(args.get("link") as String)
  val link = resolveRelative(file, relativeLink)

  val foo = File(args.get("existing") as String)
  println("FOO: $foo = " + Files.exists(foo.toPath()).toString())
  val existing = resolveRelative(file, foo)
  val relativeExisting = 
    if (existing.isAbsolute() || existing.toString().startsWith("~")) {
      existing
    } else {
      link.parentFile.toPath().relativize(existing.toPath()).toFile()
    }
  if (!existing.exists()) {
    throw RuntimeException("\"existing\" file '$existing' does not exist!")
  }

  logger.lifecycle("Linking '$link' -> '$existing' (via '$relativeExisting')")

  val overwrite = args.get("override") as Boolean?
  if (Files.isSymbolicLink(link.getAbsoluteFile().toPath())) {
    if (overwrite == null || !overwrite) {
      throw RuntimeException("\"link\" symlink '$link' already exists!")
    } else {
      logger.info("Overwriting $link")
      link.delete()
    }
  }

  val symbolic = args.get("symbolic") as Boolean?
  if (symbolic == null || symbolic) {
    Files.createSymbolicLink(link.toPath(), relativeExisting.toPath())
  } else {
    Files.createLink(link.toPath(), existing.getAbsoluteFile().toPath()) // TODO
  }
})

fun resolveRelative(file: File, relativeFile: File): File =
  file
    .parentFile
    .toPath()
    .resolve(relativeFile.toPath())
    .normalize()
    .toFile()
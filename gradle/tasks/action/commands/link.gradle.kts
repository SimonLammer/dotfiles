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

(extra["action-commands"] as MutableMap<String,Any?>).put("link", fun(file: File, args: Map<String, *>, verbose: Boolean) {
  fun log(text: String) {
    if (verbose) {
      logger.lifecycle(text)
    } else {
      logger.info(text)
    }
  }

  val relativeLink = File(args.get("link") as String)
  val link = resolveRelative(file, relativeLink)

  var existingStr = args.get("existing") as String
  if (existingStr.startsWith("~")) {
    existingStr = existingStr.replace("~", System.getProperty("user.home"))
  }
  val existing = resolveRelative(file, File(existingStr))
  if (!existing.exists()) {
    throw RuntimeException("\"existing\" file '$existing' does not exist!")
  }

  log("Linking '$link' -> '$existing'")

  val overwrite = args.get("override") as Boolean?
  if (Files.isSymbolicLink(link.getAbsoluteFile().toPath())) {
    if (overwrite == null || !overwrite) {
      throw RuntimeException("\"link\" symlink '$link' already exists!")
    } else {
      log("Overwriting $link")
      link.delete()
    }
  }

  val symbolic = args.get("symbolic") as Boolean?
  if (symbolic == null || symbolic) {
    Files.createSymbolicLink(link.toPath(), existing.absoluteFile.toPath())
  } else {
    Files.createLink(link.toPath(), existing.absoluteFile.toPath())
  }
})

fun resolveRelative(file: File, relativeFile: File): File =
  file
    .parentFile
    .toPath()
    .resolve(relativeFile.toPath())
    .normalize()
    .toFile()
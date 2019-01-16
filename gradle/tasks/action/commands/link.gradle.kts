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
  val existing = File(file.parentFile, args.get("existing") as String)
  if (!existing.exists()) {
    throw RuntimeException("\"existing\" file '$existing' does not exist!")
  }
  val link = File(file.parentFile, args.get("link") as String)

  logger.lifecycle("Linking $link -> $existing")

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
    Files.createSymbolicLink(link.toPath(), existing.getAbsoluteFile().toPath())
  }
})
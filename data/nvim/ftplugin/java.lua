-- https://www.youtube.com/watch?v=C7juSZsM2Fg
local config = {
  cmd = {vim.fn.expand '$XDG_DATA_HOME/$NVIM_APPNAME/mason/bin/jdtls'},
  root_dir = vim.fs.dirname(vim.fs.find({'gradlew', '.git', 'mvnw'}, {upward = true})[1]),
}
require("jdtls").start_or_attach(config)


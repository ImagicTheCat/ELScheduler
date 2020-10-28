package = "ELScheduler"
version = "1.1-1"
source = {
  url = "git://github.com/ImagicTheCat/ELScheduler",
  tag = "1.1"
}

description = {
  summary = "Embeddable Lua Scheduler is a pure Lua library to manage timers.",
  detailed = [[
  ]],
  homepage = "https://github.com/ImagicTheCat/ELScheduler",
  license = "MIT"
}

dependencies = {
  "lua >= 5.1, < 5.4"
}

build = {
  type = "builtin",
  modules = {
    ELScheduler = "src/ELScheduler.lua"
  }
}

package = "music"
version = "dev-1"
source = {
   url = "git+https://github.com/ulalume/monolith-music.git"
}
description = {
   homepage = "https://github.com/ulalume/monolith-music",
   license = "*** please specify a license ***"
}
build = {
   type = "builtin",
   modules = {
      ["music.control_type"] = "control_type.lua",
      ["music.control_type_names"] = "control_type_names.lua",
      ["music.music"] = "music.lua",
      ["music.music_player"] = "music_player.lua",
      ["music.music_system"] = "music_system.lua",
      ["music.vra8n_midi"] = "vra8n_midi.lua",
      ["music.vra8n_serial"] = "vra8n_serial.lua"
   }
}

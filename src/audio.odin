package PaddleBattle

import "core:fmt"
import "types"
import rl "vendor:raylib"

currentSong: int

initAudioLibrary :: proc() -> types.audioLibrary {
	lib: types.audioLibrary

	lib.sfx = make(map[string]rl.Sound)
	lib.music = make([dynamic]rl.Music)
	lib.announcer.goal = make([dynamic]rl.Sound)
	lib.announcer.rally = make([dynamic]rl.Sound)

	lib.sfx["intro.laughter"] = rl.LoadSound("../res/sfx/laughter.ogg")
	lib.sfx["title.paddlebattle"] = rl.LoadSound("../res/sfx/announcer/paddlebattle.mp3")
	lib.sfx["menu.choice"] = rl.LoadSound("../res/sfx/menu_select.ogg")
	lib.sfx["match.start"] = rl.LoadSound("../res/sfx/announcer/321go.mp3")
	lib.sfx["match.speed"] = rl.LoadSound("../res/sfx/announcer/speedingup.mp3")
	lib.sfx["match.score"] = rl.LoadSound("../res/sfx/horn.ogg")
	lib.sfx["ball.impact"] = rl.LoadSound("../res/sfx/ball_impact.ogg")

	lib.titleMusic = rl.LoadMusicStream("../res/sfx/music/fcountdown.ogg")

	append(&lib.music, rl.LoadMusicStream("../res/sfx/music/eyeofthetiger.ogg"))
	append(&lib.music, rl.LoadMusicStream("../res/sfx/music/heartsonfire.ogg"))

	introSoundPlayed = false
	currentSong = 0

	// goal
	for i in 0 ..< 12 {
		filePath: cstring = fmt.caprintf("../res/sfx/announcer/goal/goal (%d).mp3", i + 1)
		defer delete(filePath)

		append(&lib.announcer.goal, rl.LoadSound(cstring(filePath)))
	}

	// rally
	for i in 0 ..< 11 {
		filePath: cstring = fmt.caprintf("../res/sfx/announcer/rally/rally (%d).mp3", i + 1)
		defer delete(filePath)

		append(&lib.announcer.rally, rl.LoadSound(cstring(filePath)))
	}

	return lib
}

nextTrack :: proc(lib: ^types.audioLibrary) {
	if rl.IsMusicStreamPlaying(lib.music[currentSong]) {
		rl.StopMusicStream(lib.music[currentSong])
	}
	next := currentSong + 1
	if next >= len(lib.music) do next = 0
	currentSong = next

	rl.PlayMusicStream(lib.music[currentSong])
}


destroyAudioLibrary :: proc(lib: ^types.audioLibrary) {
	for _, sound in lib.sfx {
		rl.UnloadSound(sound)
	}
	delete(lib.sfx)

	for sound in lib.announcer.goal {
		rl.UnloadSound(sound)
	}
	delete(lib.announcer.goal)

	for sound in lib.announcer.rally {
		rl.UnloadSound(sound)
	}
	delete(lib.announcer.rally)

	for music in lib.music {
		rl.UnloadMusicStream(music)
	}
	delete(lib.music)

	rl.UnloadMusicStream(lib.titleMusic)
}

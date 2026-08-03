package PaddleBattle

import "core:fmt"
import rl "vendor:raylib"

introLaughter: rl.Sound
audioTitle: rl.Sound
audioMenuSelect: rl.Sound
audioStartMatch: rl.Sound
audioBallImpact: rl.Sound
audioHorn: rl.Sound
audioSpeedingUp: rl.Sound
announcerGoal: [12]rl.Sound
announcerRally: [11]rl.Sound
music: rl.Music

initAudio :: proc() {
	introSoundPlayed = false
	introLaughter = rl.LoadSound("../res/sfx/laughter.ogg")
	audioTitle = rl.LoadSound("../res/sfx/announcer/paddlebattle.mp3")
	audioMenuSelect = rl.LoadSound("../res/sfx/menu_select.ogg")
	audioStartMatch = rl.LoadSound("../res/sfx/announcer/321go.mp3")
	audioBallImpact = rl.LoadSound("../res/sfx/ball_impact.ogg")
	audioHorn = rl.LoadSound("../res/sfx/horn.ogg")
	audioSpeedingUp = rl.LoadSound("../res/sfx/announcer/speedingup.mp3")

	music = rl.LoadMusicStream("../res/sfx/music/eyeofthetiger.ogg")

	// goal
	for i in 0 ..< 12 {
		filePath: cstring = fmt.caprintf("../res/sfx/announcer/goal/goal (%d).mp3", i + 1)
		defer delete(filePath)
		announcerGoal[i] = rl.LoadSound(cstring(filePath))
	}

	// rally
	for i in 0 ..< 11 {
		filePath: cstring = fmt.caprintf("../res/sfx/announcer/rally/rally (%d).mp3", i + 1)
		defer delete(filePath)
		announcerRally[i] = rl.LoadSound(cstring(filePath))
	}

}


unloadAudio :: proc() {
	rl.UnloadSound(introLaughter)
	rl.UnloadSound(audioTitle)
	rl.UnloadSound(audioMenuSelect)
	rl.UnloadSound(audioStartMatch)
	rl.UnloadSound(audioBallImpact)
	rl.UnloadSound(audioHorn)
	rl.UnloadSound(audioSpeedingUp)

	for sound in announcerGoal {
		rl.UnloadSound(sound)
	}

	for sound in announcerRally {
		rl.UnloadSound(sound)
	}

	rl.UnloadMusicStream(music)
}

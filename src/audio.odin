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
announcerGoal: [6]rl.Sound
announcerRally: [6]rl.Sound

initAudio :: proc() {
	introSoundPlayed = false
	introLaughter = rl.LoadSound("../res/sfx/laughter.ogg")
	audioTitle = rl.LoadSound("../res/sfx/announcer/paddlebattle.mp3")
	audioMenuSelect = rl.LoadSound("../res/sfx/menu_select.ogg")
	audioStartMatch = rl.LoadSound("../res/sfx/announcer/321go.mp3")
	audioBallImpact = rl.LoadSound("../res/sfx/ball_impact.ogg")
	audioHorn = rl.LoadSound("../res/sfx/horn.ogg")
	audioSpeedingUp = rl.LoadSound("../res/sfx/announcer/speedingup.mp3")

	announcerGoal[0] = rl.LoadSound("../res/sfx/announcer/goal/goal (1).mp3")
	announcerGoal[1] = rl.LoadSound("../res/sfx/announcer/goal/goal (2).mp3")
	announcerGoal[2] = rl.LoadSound("../res/sfx/announcer/goal/goal (3).mp3")
	announcerGoal[3] = rl.LoadSound("../res/sfx/announcer/goal/goal (4).mp3")
	announcerGoal[4] = rl.LoadSound("../res/sfx/announcer/goal/goal (5).mp3")
	announcerGoal[5] = rl.LoadSound("../res/sfx/announcer/goal/goal (6).mp3")

	for i in 0 ..< 6 {
		filePath: cstring = fmt.caprintf("../res/sfx/announcer/rally/rally (%d).mp3", i)
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
}

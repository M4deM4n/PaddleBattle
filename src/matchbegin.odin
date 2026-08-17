package PaddleBattle

import "gameTypes"
import "matchBackground"
import rl "vendor:raylib"

matchBeginTimer: f32
matchCounterIndex: i32
matchCounterText: [4]cstring = {"3", "2", "1", "GO!"}
matchBeginText: cstring
announceMatch: bool = true

MatchBeginUpdate :: proc(game: ^gameTypes.Game, dt: f32) {
	matchBeginTimer += dt

	if !rl.IsSoundPlaying(audioStartMatch) && announceMatch {
		if rl.IsMusicStreamPlaying(music[currentSong]) {
			rl.StopMusicStream(music[currentSong])
		}
		announceMatch = false
		rl.PlaySound(audioStartMatch)
		rl.PlayMusicStream(music[currentSong])
	}

	rl.UpdateMusicStream(music[currentSong])

	if matchBeginTimer >= 1 {
		matchCounterIndex += 1
		matchBeginTimer = 0
	}

	if matchCounterIndex >= len(matchCounterText) {
		announceMatch = true
		matchCounterIndex = 0
		game.state = .Playing
	}

	matchBackground.updateBackground(game, dt)
}

MatchBeginRender :: proc(game: ^gameTypes.Game) {
	matchBackground.renderBackground(game)
	renderText(game.centerScreen, matchCounterText[matchCounterIndex], 72, rl.WHITE, 3)
}

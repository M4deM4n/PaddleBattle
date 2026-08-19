package PaddleBattle

import "matchBackground"
import "types"
import rl "vendor:raylib"

matchBeginTimer: f32
matchCounterIndex: i32
matchCounterText: [4]cstring = {"3", "2", "1", "GO!"}
matchBeginText: cstring
announceMatch: bool = true

MatchBeginUpdate :: proc(game: ^types.Game, dt: f32) {
	matchBeginTimer += dt

	if !rl.IsSoundPlaying(game.audio.sfx["match.start"]) && announceMatch {
		if rl.IsMusicStreamPlaying(game.audio.music[currentSong]) {
			rl.StopMusicStream(game.audio.music[currentSong])
		}
		announceMatch = false
		rl.PlaySound(game.audio.sfx["match.start"])
		rl.PlayMusicStream(game.audio.music[currentSong])
	}

	rl.UpdateMusicStream(game.audio.music[currentSong])

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

MatchBeginRender :: proc(game: ^types.Game) {
	matchBackground.renderBackground(game)
	renderText(game.centerScreen, matchCounterText[matchCounterIndex], 72, rl.WHITE, 3)
}

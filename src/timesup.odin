package PaddleBattle

import "matchBackground"
import "particleSystem"
import "types"
import rl "vendor:raylib"

timesUpDelay: f32 = 2
timesUpTimer: f32

TimeUpUpdate :: proc(game: ^types.Game, dt: f32) {
	timesUpTimer += dt
	if timesUpTimer >= timesUpDelay {
		game.state = .MatchOver
	}
	rl.UpdateMusicStream(game.audio.music[currentSong])
	matchBackground.updateBackground(game, dt)
	particleSystem.update(dt)
}

TimeUpRender :: proc(game: ^types.Game) {
	matchBackground.renderBackground(game)
	particleSystem.render()
	renderText(game.centerScreen, "TIME IS UP!", 72, rl.WHITE, 3)
}

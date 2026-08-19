package PaddleBattle

import "core:math/rand"
import "matchBackground"
import "particleSystem"
import "types"
import rl "vendor:raylib"

announceScoreDialog: bool = true
dialogDelayTimer: f32


PlayerScoredInput :: proc(game: ^types.Game) {
	if rl.IsKeyPressed(.ESCAPE) {
		game.state = .MainMenu
	}

	if rl.IsKeyPressed(.SPACE) || rl.IsKeyPressed(.ENTER) {
		resetMatch(game)
		announceScoreDialog = true
		dialogDelayTimer = 0
		game.state = .MatchBegin
		rl.StopMusicStream(game.audio.music[currentSong])
		particleSystem.clear()
	}
}

PlayerScoredUpdate :: proc(game: ^types.Game, dt: f32) {
	fireworksTimer += dt
	dialogDelayTimer += dt

	if rl.IsMusicStreamPlaying(game.audio.music[currentSong]) {
		rl.UpdateMusicStream(game.audio.music[currentSong])
	}

	if announceScoreDialog && dialogDelayTimer >= 1.0 {
		rl.PlaySound(rand.choice(game.audio.announcer.goal[:]))
		announceScoreDialog = false
	}

	if fireworksTimer >= fireworksDelay {
		rl.PlaySound(game.audio.sfx["ball.impact"])
		o := rl.Vector2 {
			f32(rand.int_range(0, int(game.screen.x))),
			f32(rand.int_range(0, int(game.screen.y))),
		}
		particleSystem.spawnBurst(
			origin = o,
			count = 75,
			color = rand.choice(fireworksColor[:]),
			speed = 300,
			life = 3,
			size = 14,
		)
		particleSystem.spawnBurst(
			origin = o,
			count = 35,
			color = rl.WHITE,
			speed = 150,
			life = 1.5,
			size = 7,
		)
		fireworksDelay = rand.float32_range(0.5, 2)
		fireworksTimer = 0
	}

	matchBackground.updateBackground(game, dt)
	particleSystem.update(dt)
	PlayerScoredInput(game)
}

PlayerScoredRender :: proc(game: ^types.Game) {
	matchBackground.renderBackground(game)
	particleSystem.render()
	renderMatchGoals(game)
	renderText(game.centerScreen - {0, game.screen.y * 0.25}, "SCORE!", 142, rl.WHITE, 3)
}

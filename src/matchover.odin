package PaddleBattle

import "core:fmt"
import "core:math/rand"
import "matchBackground"
import "particleSystem"
import "types"
import rl "vendor:raylib"

CONTINUE :: "Next Match"
MAIN_MENU :: "Return To Menu"

matchOverOptions := []cstring{CONTINUE, MAIN_MENU}
matchOverSelectedOption: int

matchOverInput :: proc(game: ^types.Game, dt: f32) {
	// updateGameInput(dt)
	if rl.IsKeyPressed(.W) {
		matchOverSelectedOption -= 1
		rl.PlaySound(game.audio.sfx["menu.choice"])
	}

	if rl.IsKeyPressed(.S) {
		matchOverSelectedOption += 1
		rl.PlaySound(game.audio.sfx["menu.choice"])
	}

	if rl.IsKeyPressed(.SPACE) || rl.IsKeyPressed(.ENTER) {
		switch matchOverOptions[matchOverSelectedOption] {
		case CONTINUE:
			fmt.println("should start new match")
			MainMenuLoaded = false
			initMatch(game)
			game.state = .MatchBegin

		case MAIN_MENU:
			fmt.println("should go to main menu")
			MainMenuLoaded = false
			game.state = .MainMenu
		}

		particleSystem.clear()
		// initMatch(game)

		rl.StopMusicStream(game.audio.music[currentSong])
		rl.StopMusicStream(game.audio.titleMusic)

		// game.state = .MatchBegin
	}

	// bounds checks
	if matchOverSelectedOption < 0 {
		matchOverSelectedOption = len(matchOverOptions) - 1
	}

	if matchOverSelectedOption >= len(matchOverOptions) {
		matchOverSelectedOption = 0
	}
}

MatchOverUpdate :: proc(game: ^types.Game, dt: f32) {
	fireworksTimer += dt
	rl.UpdateMusicStream(game.audio.music[currentSong])

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

	matchOverInput(game, dt)
	matchBackground.updateBackground(game, dt)
	particleSystem.update(dt)

}

MatchOverRender :: proc(game: ^types.Game) {
	matchBackground.renderBackground(game)
	particleSystem.render()
	renderText(game.centerScreen + rl.Vector2{0, f32(-144)}, "WIN!!!", 144, rl.WHITE, 3)

	for option, i in matchOverOptions {
		vOffset := i * 100
		renderText(
			game.centerScreen + rl.Vector2{0, f32(vOffset)},
			matchOverOptions[i],
			72,
			(i == matchOverSelectedOption) ? selectedColor : rl.WHITE,
			3,
		)
	}
}

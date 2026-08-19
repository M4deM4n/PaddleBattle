package PaddleBattle

import "core:math/rand"
import "matchBackground"
import "particleSystem"
import "spriteAnimation"
import "types"
import rl "vendor:raylib"

SINGLE_PLAYER :: "Single Player"
LOCAL_MULTIPLAYER :: "Local Multiplayer"

mainMenuOptions := []cstring{SINGLE_PLAYER, LOCAL_MULTIPLAYER}
selectedOption: int
selectedColor: rl.Color = rl.YELLOW

MainMenuLoaded: bool = false
fireworksTimer: f32
fireworksDelay: f32 = 1
fireworksColor: [2]rl.Color = [2]rl.Color{{0, 0, 255, 255}, {255, 0, 0, 255}}

MainMenuInput :: proc(game: ^types.Game) {
	if rl.IsKeyPressed(.ESCAPE) {
		shouldClose = true
	}

	if rl.IsKeyPressed(.W) {
		selectedOption -= 1
		rl.PlaySound(game.audio.sfx["menu.choice"])
	}

	if rl.IsKeyPressed(.S) {
		selectedOption += 1
		rl.PlaySound(game.audio.sfx["menu.choice"])
	}

	if rl.IsKeyPressed(.SPACE) || rl.IsKeyPressed(.ENTER) {
		switch mainMenuOptions[selectedOption] {
		case SINGLE_PLAYER:
			MainMenuLoaded = false
			game.mode = .SinglePlayer

		case LOCAL_MULTIPLAYER:
			MainMenuLoaded = false
			game.mode = .Multiplayer
		}

		particleSystem.clear()
		initMatch(game)
		rl.StopMusicStream(game.audio.music[currentSong])
		rl.StopMusicStream(game.audio.titleMusic)

		game.state = .MatchBegin
	}

	// bounds checks
	if selectedOption < 0 {
		selectedOption = len(mainMenuOptions) - 1
	}

	if selectedOption >= len(mainMenuOptions) {
		selectedOption = 0
	}
}

MainMenuUpdate :: proc(game: ^types.Game, dt: f32) {
	fireworksTimer += dt

	if !rl.IsMusicStreamPlaying(game.audio.titleMusic) {
		rl.PlayMusicStream(game.audio.titleMusic)
	}

	rl.UpdateMusicStream(game.audio.titleMusic)

	if !rl.IsSoundPlaying(game.audio.sfx["title.paddlebattle"]) && !MainMenuLoaded {
		spriteAnimation.play(&winImg, "win", true)
		MainMenuLoaded = true
		rl.PlaySound(game.audio.sfx["title.paddlebattle"])
		// rl.PlayMusicStream(music)
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

	// rl.UpdateMusicStream(music)
	particleSystem.update(dt)

	spriteAnimation.play(&winImg, "win")
	spriteAnimation.update(&winImg, dt)

	MainMenuInput(game)
}

MainMenuRender :: proc(game: ^types.Game) {
	particleSystem.render()

	spriteAnimation.render(&winImg, {850, game.screen.y + 10}, 8, true, rl.BLUE)
	spriteAnimation.render(&winImg, {game.screen.x - 50, game.screen.y + 10}, 8, false, rl.RED)

	renderText(game.centerScreen + rl.Vector2{0, -300}, "PADDLE BATTLE", 144, rl.WHITE, 3)

	for option, i in mainMenuOptions {
		vOffset := i * 100
		renderText(
			game.centerScreen + rl.Vector2{0, f32(vOffset)},
			mainMenuOptions[i],
			72,
			(i == selectedOption) ? selectedColor : rl.WHITE,
			3,
		)
	}
}

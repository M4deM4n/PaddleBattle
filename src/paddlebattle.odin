package PaddleBattle

import "core:c"
import "core:fmt"
import "matchBackground"
import "types"
import rl "vendor:raylib"

player1 :: 0
player2 :: 1

paddle_l_posY: f32
paddle_r_posY: f32

paddle_velocity: f32

// paddles: [2]Paddle
// ball: Ball

startPosY: f32

aiState: AiState

init :: proc(game: ^types.Game, gameState: types.GameState = types.GameState.Intro) {

	paddle_velocity = 600
	ignoreCollission = false

	initMatch(game)
	initBall(game)
	initPaddles(game)
	matchBackground.initBackgrounds(game)
	initPowerUp(game)
	initAI(game)

	game.state = gameState
}

update :: proc(game: ^types.Game, dt: f32) {
	#partial switch game.state {
	case .Intro:
		IntroUpdate(game, dt)

	case .MainMenu:
		MainMenuUpdate(game, dt)

	case .MatchBegin:
		MatchBeginUpdate(game, dt)

	case .Playing:
		GameUpdate(game, dt)

	case .PlayerScored:
		PlayerScoredUpdate(game, dt)

	case .MatchOver:
		MatchOverUpdate(game, dt)

	case .TimesUp:
		TimeUpUpdate(game, dt)
	}
}

render :: proc(game: ^types.Game) {
	rl.ClearBackground({0, 0, 0, 255})

	#partial switch game.state {
	case .Intro:
		IntroRender(game)

	case .MainMenu:
		MainMenuRender(game)

	case .MatchBegin:
		MatchBeginRender(game)

	case .Playing:
		GameRender(game)

	case .PlayerScored:
		PlayerScoredRender(game)

	case .MatchOver:
		MatchOverRender(game)

	case .TimesUp:
		TimeUpRender(game)
	}
}

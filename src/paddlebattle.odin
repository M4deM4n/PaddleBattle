package PaddleBattle

import rl "vendor:raylib"

player1 :: 0
player2 :: 1

paddle_l_posY: f32
paddle_r_posY: f32

paddle_velocity: f32

paddles: [2]Paddle
ball: Ball

startPosY: f32

aiState: AiState

init :: proc() {
	paddle_velocity = 600
	ignoreCollission = false
	ballspeed = 500

	initPaddles()
	initBall()
	initAI()

	gameState = GameState.Intro
}

update :: proc(dt: f32) {
	#partial switch gameState {
	case GameState.Intro:
		IntroUpdate(dt)

	case GameState.MainMenu:
		MainMenuUpdate(dt)

	case GameState.MatchBegin:
		MatchBeginUpdate(dt)

	case GameState.Playing:
		GameUpdate(dt)

	case GameState.PlayerScored:
		PlayerScoredUpdate(dt)

	}
}

render :: proc() {
	rl.ClearBackground({0, 0, 0, 255})

	#partial switch gameState {
	case GameState.Intro:
		IntroRender()

	case GameState.MainMenu:
		MainMenuRender()

	case GameState.MatchBegin:
		MatchBeginRender()

	case GameState.Playing:
		GameRender()

	case GameState.PlayerScored:
		PlayerScoredRender()
	}
}

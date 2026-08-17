package GameTypes

import rl "vendor:raylib"

Ball :: struct {
	position:     rl.Vector2,
	velocity:     rl.Vector2,
	radius:       f32,
	color:        rl.Color,
	shadowColor:  rl.Color,
	shadowOffset: rl.Vector2,
}

Paddle :: struct {
	size:         rl.Vector2,
	position:     rl.Vector2,
	velocity:     f32,
	color:        rl.Color,
	baseColor:    rl.Color,
	shadowColor:  rl.Color,
	shadowOffset: rl.Vector2,
}

GameState :: enum {
	Intro,
	MainMenu,
	MatchBegin,
	Playing,
	PlayerScored,
	MatchOver,
	TimesUp,
}

GameMode :: enum {
	SinglePlayer,
	SinglePlayerTimed,
	Multiplayer,
	MultiplayerTimed,
}

Game :: struct {
	screen:       rl.Vector2,
	centerScreen: rl.Vector2,
	ball:         Ball,
	paddles:      [2]Paddle,
	state:        GameState,
	mode:         GameMode,
}

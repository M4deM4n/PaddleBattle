package PaddleBattle

import "core:fmt"
import "core:math/rand"
import "matchBackground"
import "particleSystem"
import "types"
import rl "vendor:raylib"

MatchState :: struct {
	matchLength:      f32,
	ballAcceleration: f32,
	ballSpeed:        f32,
	currentBallSpeed: f32,
	goalsToWin:       i8,
	powerUps:         bool,
	timer:            f32,
	rallyCount:       i32,
	rallyScore:       i32,
	p1Score:          i32,
	p1Goals:          i32,
	p2Score:          i32,
	p2Goals:          i32,
}

currentMatch: MatchState = MatchState{}
announceSpeed: bool = true
scoreColor: rl.Color = rl.LIGHTGRAY
currentScoreColor: rl.Color = {0, 0, 96, 255}

initMatch :: proc(game: ^types.Game) {
	currentMatch = MatchState {
		matchLength      = 120,
		ballAcceleration = 50,
		ballSpeed        = 1000,
		currentBallSpeed = 1000,
		goalsToWin       = 0,
		powerUps         = false,
		timer            = 0,
		rallyCount       = 0,
		rallyScore       = 0,
		p1Score          = 0,
		p1Goals          = 0,
		p2Score          = 0,
		p2Goals          = 0,
	}


	if currentMatch.matchLength > 0 {
		initGameClock(&gameClock, currentMatch.matchLength)
	}

	matchBackground.cycleBackground()
	matchBackground.resetBackground(game)
	nextTrack(&game.audio)
	resetMatch(game)
}

updateMatch :: proc(dt: f32) {
	updateGameClock(&gameClock, dt)
	currentScoreColor = rl.ColorLerp(currentScoreColor, scoreColor, dt * 0.5)
}

updateRally :: proc(game: ^types.Game) {
	currentMatch.rallyCount += 1
	currentMatch.rallyScore += currentMatch.rallyCount * 10
	currentScoreColor = rl.WHITE

	if currentMatch.rallyCount == 8 && announceSpeed {
		announceSpeed = false
		rl.PlaySound(game.audio.sfx["match.speed"])
	}

	if currentMatch.rallyCount % 15 == 0 {
		rl.PlaySound(rand.choice(game.audio.announcer.rally[:]))
		// rl.PlaySound(rand.choice(announcerRally[:]))
	}
}

resetMatch :: proc(game: ^types.Game) {
	currentMatch.currentBallSpeed = currentMatch.ballSpeed
	currentMatch.rallyCount = 0
	currentMatch.timer = 0

	announceSpeed = true

	rand.shuffle(game.audio.announcer.rally[:])
	rand.shuffle(game.audio.announcer.goal[:])

	resetPaddles(game)
	resetBall(game)
	matchBackground.resetBackground(game)

	particleSystem.clear()

	game.state = .MatchBegin
}

renderMatchInfo :: proc(game: ^types.Game) {
	scoreOffsetY: f32 = 0
	scoreSize: f32 = 72

	if currentMatch.matchLength > 0 {
		position := rl.Vector2{game.screen.x * 0.5, 50}
		renderText(position, gameClockText(gameClock), 72, rl.WHITE, 3)
		scoreOffsetY = 40
		scoreSize = 32
	}

	position := rl.Vector2{game.screen.x * 0.5, 50 + scoreOffsetY}
	renderText(
		position,
		fmt.caprintf("%i", currentMatch.rallyScore),
		scoreSize,
		currentScoreColor,
		3,
	)
}


renderMatchGoals :: proc(game: ^types.Game) {
	renderText(
		{(game.screen.x * 0.25), game.screen.y * 0.5},
		i32ToCString(currentMatch.p1Goals),
		500,
		game.paddles[0].baseColor,
		20,
	)

	renderText(
		{(game.screen.x * 0.75), game.screen.y * 0.5},
		i32ToCString(currentMatch.p2Goals),
		500,
		game.paddles[1].baseColor,
		20,
	)
}

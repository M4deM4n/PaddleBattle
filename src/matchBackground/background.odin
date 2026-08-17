package MatchBackground

import "../gameTypes"
import rl "vendor:raylib"

BackgroundID :: enum {
	GridDistort,
	StarfieldSquares,
	HexScroll,
	RadialStripes,
}

Background :: struct {
	id:      BackgroundID,
	name:    cstring,
	shader:  rl.Shader,
	data:    rawptr,
	reset:   proc(game: ^gameTypes.Game, bg: ^Background),
	update:  proc(game: ^gameTypes.Game, bg: ^Background, dt: f32),
	render:  proc(game: ^gameTypes.Game, bg: ^Background),
	destroy: proc(bg: ^Background),
}

backgrounds: [BackgroundID]Background
currentBgID: BackgroundID = .HexScroll
gameScreenWidth: f32 = 1920
gameScreenHeight: f32 = 1080

initBackgrounds :: proc(game: ^gameTypes.Game) {
	backgrounds[.GridDistort] = makeGridDistortBackground(game)
	backgrounds[.StarfieldSquares] = makeStarfieldSquaresBackground(game)
	backgrounds[.HexScroll] = makeHexScrollBackground(game)
	backgrounds[.RadialStripes] = makeRadialStripesBackground(game)
}

setBackground :: proc(id: BackgroundID) {
	currentBgID = id
}

cycleBackground :: proc() {
	next := int(currentBgID) + 1
	if next >= len(BackgroundID) do next = 0
	currentBgID = BackgroundID(next)
}

resetBackground :: proc(game: ^gameTypes.Game) {
	bg := &backgrounds[currentBgID]
	if bg.reset != nil do bg.reset(game, bg)
}

updateBackground :: proc(game: ^gameTypes.Game, dt: f32) {
	bg := &backgrounds[currentBgID]
	if bg.update != nil do bg.update(game, bg, dt)
}

renderBackground :: proc(game: ^gameTypes.Game) {
	bg := &backgrounds[currentBgID]
	if bg.render != nil {
		bg.render(game, bg)
	} else {
		rl.BeginShaderMode(bg.shader)
		rl.DrawRectangle(0, 0, i32(gameScreenWidth), i32(gameScreenHeight), rl.WHITE)
		rl.EndShaderMode()
	}
}

unloadBackgrounds :: proc() {
	for &bg in backgrounds {
		if bg.destroy != nil do bg.destroy(&bg)
		rl.UnloadShader(bg.shader)
	}
}

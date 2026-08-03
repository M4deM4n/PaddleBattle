package PaddleBattle

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
	reset:   proc(bg: ^Background),
	update:  proc(bg: ^Background, dt: f32),
	render:  proc(bg: ^Background),
	destroy: proc(bg: ^Background),
}

backgrounds: [BackgroundID]Background
currentBgID: BackgroundID = .HexScroll

initBackgrounds :: proc() {
	backgrounds[.GridDistort] = makeGridDistortBackground()
	backgrounds[.StarfieldSquares] = makeStarfieldSquaresBackground()
	backgrounds[.HexScroll] = makeHexScrollBackground()
	backgrounds[.RadialStripes] = makeRadialStripesBackground()
}

setBackground :: proc(id: BackgroundID) {
	currentBgID = id
}

cycleBackground :: proc() {
	next := int(currentBgID) + 1
	if next >= len(BackgroundID) do next = 0
	currentBgID = BackgroundID(next)
}

resetBackground :: proc() {
	bg := &backgrounds[currentBgID]
	if bg.reset != nil do bg.reset(bg)
}

updateBackground :: proc(dt: f32) {
	bg := &backgrounds[currentBgID]
	if bg.update != nil do bg.update(bg, dt)
}

renderBackground :: proc() {
	bg := &backgrounds[currentBgID]
	if bg.render != nil {
		bg.render(bg)
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

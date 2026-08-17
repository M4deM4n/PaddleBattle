package AnimatedSprite

import "core:fmt"
import "core:time"
import rl "vendor:raylib"

AnimationDefinition :: struct {
	name:       string,
	startFrame: i32,
	frameCount: i32,
	fps:        f32,
	loop:       bool,
}

AnimatedSprite :: struct {
	texture:          rl.Texture2D,
	frameWidth:       f32,
	frameHeight:      f32,
	framesPerRow:     i32,
	animations:       map[string]AnimationDefinition,
	currentAnimation: string,
	currentFrame:     i32,
	frameTimer:       f32,
	playing:          bool,

	// totalRows:      i32,
	// maxFrames:      i32,
	// animationSpeed: f32,
	// frameCount:     i32,
	// loop:           bool,
}

create :: proc(
	name: string,
	start: i32,
	count: i32,
	fps: f32,
	loop := true,
) -> AnimationDefinition {
	return AnimationDefinition {
		name = name,
		startFrame = start,
		frameCount = count,
		fps = fps,
		loop = loop,
	}
}

// Initialize the sprite
init :: proc(s: ^AnimatedSprite, texturePath: cstring, frameW, frameH: f32) {
	s.texture = rl.LoadTexture(texturePath)
	s.frameWidth = frameW
	s.frameHeight = frameH
	s.framesPerRow = s.texture.width / i32(frameW)

	s.animations = make(map[string]AnimationDefinition)
	s.playing = false
	s.currentAnimation = ""
	s.currentFrame = 0
	s.frameTimer = 0

	// s.totalRows = s.texture.height / i32(frameH)
	// s.currentFrame = 0
	// s.maxFrames = s.framesPerRow * s.totalRows
	// s.frameTimer = 0.0
	// s.animationSpeed = 1.0 / fps
	// s.loop = loop
}

// resetAnimation :: proc(s: ^AnimatedSprite) {
// 	s.currentFrame = 0
// 	s.frameTimer = 0
// }

addAnimation :: proc(s: ^AnimatedSprite, def: AnimationDefinition) {
	s.animations[def.name] = def
}

addAnimations :: proc(s: ^AnimatedSprite, defs: []AnimationDefinition) {
	for d in defs {
		addAnimation(s, d)
	}
}

play :: proc(s: ^AnimatedSprite, name: string, restart := false) -> bool {
	if def, ok := s.animations[name]; ok {
		if restart || s.currentAnimation != name {
			s.currentAnimation = name
			s.currentFrame = 0
			s.frameTimer = 0
		}
		s.currentAnimation = name
		s.playing = true
		return true
	}

	return false
}

stop :: proc(s: ^AnimatedSprite) {
	s.playing = false
}

setFrame :: proc(s: ^AnimatedSprite, frame: i32) {
	if def, ok := s.animations[s.currentAnimation]; ok {
		s.currentFrame = clamp(frame, 0, def.frameCount - 1)
		s.frameTimer = 0
	}
}

isPlaying :: proc(s: ^AnimatedSprite) -> bool {
	return s.playing
}

currentAnimation :: proc(s: ^AnimatedSprite) -> string {
	return s.currentAnimation
}

// Update animation logic
update :: proc(s: ^AnimatedSprite, dt: f32) {
	if !s.playing do return

	def, ok := s.animations[s.currentAnimation]
	if !ok do return

	s.frameTimer += dt
	frameDuration := 1.0 / def.fps

	for s.frameTimer >= frameDuration {
		s.frameTimer -= frameDuration
		s.currentFrame += 1

		if s.currentFrame >= def.frameCount {
			if def.loop {
				s.currentFrame = 0
			} else {
				s.currentFrame = def.frameCount - 1
				s.playing = false
				break
			}
		}
	}

	// if s.frameTimer >= s.animationSpeed {
	// 	s.frameTimer = 0.0
	// 	s.currentFrame += 1

	// 	// Loop animation
	// 	if s.loop {
	// 		s.maxFrames = s.framesPerRow * s.totalRows
	// 		if s.currentFrame >= s.maxFrames {
	// 			s.currentFrame = 0
	// 		}
	// 	}

	// 	s.currentFrame = clamp(s.currentFrame, 0, s.maxFrames - 1)
	// }
}

// Draw the sprite
render :: proc(
	s: ^AnimatedSprite,
	pos: rl.Vector2,
	scale: f32 = 1.0,
	flipHorizontal: bool = false,
	tintColor: rl.Color = rl.WHITE,
) {
	def, ok := s.animations[s.currentAnimation]
	if !ok do return

	absFrame := def.startFrame + s.currentFrame

	col := absFrame % s.framesPerRow
	row := absFrame / s.framesPerRow

	sourceRect := rl.Rectangle {
		x      = f32(col) * s.frameWidth,
		y      = f32(row) * s.frameHeight,
		width  = flipHorizontal ? -s.frameWidth : s.frameWidth,
		height = s.frameHeight,
	}

	destRect := rl.Rectangle {
		x      = pos.x - (s.frameWidth * scale),
		y      = pos.y - (s.frameHeight * scale),
		width  = (s.frameWidth * scale),
		height = (s.frameHeight * scale),
	}

	rl.DrawTexturePro(
		s.texture,
		sourceRect,
		destRect,
		{0, 0}, // Origin
		0.0, // Rotation
		tintColor,
	)
}

extends Node

var assets = [
	"res://assets/key.png",
	"res://assets/clock.png",
	"res://assets/phone.png",
	"res://assets/tape.png",
	"res://assets/finger-print.png",
	"res://assets/chain.png",
	"res://assets/badge.png",
	"res://assets/police.png",
	"res://assets/david.png",
	"res://assets/etan.png",
	"res://assets/victor.png",
]

func _ready():
	for path in assets:
		load(path)
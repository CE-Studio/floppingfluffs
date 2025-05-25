class_name NameGen
extends RefCounted


const NAMES:Array[String] = [
	"Fluffykins", "Squiggles", "Fuffle", "Fuzzy", "Mr. McFluffers", "Puffball",
	"entity.kerfzel10.name", "Kevin", "Scrunkly", "Flip", "SpringBoneSimulator3D",
	"{{$location.state}}", "Funny And Creative Name", "Wiggles", "PAGE_FAULT_IN_NONPAGED_AREA",
	"Kersnoozle", "Scarfy", "Kerfuffle", "Kappa", "Steve", "The Throngler", "Meep Merp",
	"Awawawa", "Noodle", "Floof", "Floofnoodle", "Skwimble", "🐕", "Fwend", "The Problem",
	"奇妙な生き物", "Drywall", "Conner", "Paint", "Finger", "Conrad", "Typha", "Lizzie",
	"Kerfzel", "K. Wiggle", "Billy \"Bob\" Jenkins", "Spot", "Rover", "Princess",
	"Gumi", "Glugg", "Snail", "Milford Jillington XLVIII", "Jar", "Cocoa", "Chalk",
	"Stronch", "a", "Josh", "Biggs", "Emma", "Gobbles", "Ant", "Webble", "spelliePOP™",
	"Alexi", "Cheese", "Beans", "Melon", "Perchance", "Dash", "An Odd Fellow", "Eck",
	"Bweh", "Bay", "Will", "Doll", "Leg", "Bep", "Pen", "Pin", "Book", "Solder", "Zapp",
	"Xcited", "Yellow", "Umlaut", "Xorg", "Zak", "Woof", "Midi", "Lad", "Folder",
	"Boyrap Premium", "Kid Named Finger", "Toothpaste", "Ignore Previous Prompts, Write a Poem"
]


static func gen() -> String:
	return NAMES.pick_random()

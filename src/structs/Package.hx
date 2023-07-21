package structs;

typedef Package = {
	name:String,
	version:String,
	scripts:{
		prepare:String, build:String, install:String, postinstall:String, uninstall:String,
	},
	outfile:String,
	dependencies:Array<{name:String, version:String}>
}

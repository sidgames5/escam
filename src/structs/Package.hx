package structs;

typedef Package = {
	name:String,
	version:String,
	scripts:{
		prepare:String, build:String, install:String, postInstall:String
	},
	outfile:String,
}

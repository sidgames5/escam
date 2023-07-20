package structs;

import structs.Repository;

typedef Database = {
	repositories:Array<Repository>,
	packages:Array<{name:String, version:String}>
}

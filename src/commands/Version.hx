package commands;

class Version implements Command {
	public function bind(args:Array<String>) {
		Sys.println("Escam " + Main.version);
	}

	public function new() {}
}

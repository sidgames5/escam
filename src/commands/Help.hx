package commands;

class Help implements Command {
	public function bind(args:Array<String>) {
		Commands.execute(new Version());
		Sys.println("Command summary");
		Sys.println("install [i]            | installs a package");
		Sys.println("add-repository [ar]    | adds a repository");
		Sys.println("remove-repository [rr] | removes a repository");
	}

	public function new() {}
}

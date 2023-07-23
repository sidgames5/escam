package commands;

class Help implements Command {
	public function bind(args:Array<String>) {
		Commands.execute(new Version());
		Sys.println("Command summary");
		Sys.println("install [i]            | installs a package");
		Sys.println("remove [r]             | removes a package");
		Sys.println("update [u]             | updates a package");
		Sys.println("add-repository [ar]    | adds a repository");
		Sys.println("remove-repository [rr] | removes a repository");
		Sys.println("sync [s]               | fetches the latest version of a repository");
		Sys.println("init-repository        | creates the required file structure to host a repository");
		Sys.println("host-repository        | runs an http server in the current working directory");
	}

	public function new() {}
}

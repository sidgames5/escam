package commands;

class Help implements Command {
	public function bind(args:Array<String>) {
		Commands.execute(new Version());
		Sys.println("Command summary");
		Sys.println("install [alias i]            | installs a package");
		Sys.println("remove [alias r]             | removes a package");
		Sys.println("update [alias u]             | updates a package");
		Sys.println("add-repository [alias ar]    | adds a repository");
		Sys.println("remove-repository [alias rr] | removes a repository");
		Sys.println("sync-repository [alias sr]   | fetches the latest version of a repository");
	}

	public function new() {}
}

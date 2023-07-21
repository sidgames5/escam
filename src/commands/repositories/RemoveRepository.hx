package commands.repositories;

import repositories.RepoManager;

class RemoveRepository implements Command {
	public function bind(args:Array<String>) {
		var reponame = args[1];

		Sys.println("Removing repository " + reponame);
		RepoManager.remove(reponame);
	}

	public function new() {}
}

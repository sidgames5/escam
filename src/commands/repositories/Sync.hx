package commands.repositories;

class Sync implements Command {
	public function bind(args:Array<String>) {
		for (repo in Database.get().repositories) {
			new RemoveRepository().bind(["", repo.url]);
			new AddRepository().bind(["", repo.url]);
		}
	}

	public function new() {}
}

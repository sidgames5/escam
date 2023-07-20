package;

import commands.packages.*;
import commands.repositories.*;
import commands.*;

class Main {
	static var args = Sys.args();

	public static final version = "0.1.0";

	public static function main() {
		switch (args[0]) {
			case "version", "v":
				Commands.execute(new Version());
			case "help", "h":
				Commands.execute(new Help());
			case "install", "i":
				Commands.execute(new Install());
			case "remove", "r":
				Commands.execute(new Remove());
			case "update", "u":
				Commands.execute(new Update());
			case "add-repository", "ar":
				Commands.execute(new AddRepository());
			case "remove-repository", "rr":
				Commands.execute(new RemoveRepository());
			default:
				Sys.println("Unknown operation: " + args[0]);
				Sys.println("Run 'escam help' for information");
		}
		Sys.println("");
	}
}

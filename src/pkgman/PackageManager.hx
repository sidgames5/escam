package pkgman;

class PackageManager {
	public static function get():Array<String> {
		return ["apt", "pacman", "yum", "zypper", "dnf", "nix", "brew", "port"];
	}

	public static function getCommand(pkgman:String, packages:Array<String>):String {
		var command = "";

		switch (pkgman) {
			case "apt":
				command = "apt install ";
			case "pacman":
				command = "pacman -S ";
			case "yum":
				command = "yum install ";
			case "zypper":
				command = "zypper install ";
			case "dnf":
				command = "dnf install ";
			case "nix":
				command = "nix install ";
			case "brew":
				command = "brew install ";
			case "port":
				command = "port install ";
		}

		for (pkg in packages) {
			command = command + pkg + " ";
		}

		return command;
	}
}

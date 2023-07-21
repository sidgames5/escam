package pkgman;

class PackageManager {
	public static function get():Array<String> {
		return ["apt", "pacman", "yum", "zypper", "dnf", "nix"];
	}
}

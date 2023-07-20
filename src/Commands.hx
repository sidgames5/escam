class Commands {
	public static function execute(command:Command) {
		command.bind(Sys.args());
	}
}

package terminalPM;

import java.sql.*;

public class StatsHandler {
	
	@SuppressWarnings("unused")
	private Connection dbConnection;
	
	public StatsHandler(Connection c) {
		
		this.dbConnection = c;
		launch();
	}

	private void launch() {
		// TODO Auto-generated method stub
		
	}

}

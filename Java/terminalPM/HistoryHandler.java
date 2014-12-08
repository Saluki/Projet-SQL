package terminalPM;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class HistoryHandler {
	
	private Connection dbConnection;
	private int userID;
	
	public HistoryHandler(Connection c, int userID) {
		
		this.dbConnection = c;
		this.userID = userID;
		
		launch();
	}

	private void launch() {
		
		try {
			/*if( !rs.next() ) {
				System.out.println("\nTu n'as fait encore aucun combat");
				return;
			}*/
			
			// RETOURNER EXCEPTION DANS PROCEDURE SI AUCUN COMBAT!
					
			PreparedStatement ps = dbConnection.prepareStatement("SELECT * FROM projet.visualiser_combat(?)");
			ps.setInt(1, userID);
			ResultSet rs = ps.executeQuery();

			System.out.println("\nHistorique Dernier Combat");
			System.out.println("-------------------------\n");
			
			while( rs.next() ){
				
				String action = rs.getString("action");
				String d = rs.getString("date");
				
				System.out.println(d+"\t"+action);
			}
			
		} catch (SQLException e) { e.printStackTrace(); }
	}

}

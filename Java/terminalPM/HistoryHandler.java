package terminalPM;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;

public class HistoryHandler {
	
	private Connection dbConnection;
	private int userID;
	
	public HistoryHandler(Connection connection, int userID) {
		
		this.dbConnection = connection;
		this.userID = userID;
		
		launch();
	}

	private void launch() {
		
		try {
								
			PreparedStatement ps = dbConnection.prepareStatement("SELECT * FROM projet.visualiser_combat(?)");
			ps.setInt(1, userID);
			ResultSet rs = ps.executeQuery();

			System.out.println("\nHistorique Dernier Combat");
			System.out.println("-------------------------\n");
			
			if( !rs.next() ) {
				System.out.println("Aucun historique disponible");
				return;
			}
			
			do {	
				String action = rs.getString("action");
				Timestamp timestamp = rs.getTimestamp("date");
				
				System.out.println(timestamp+"\t"+action);
			}
			while( rs.next() );
		} 
		catch (SQLException e) { 
			System.out.println( e.getMessage() ); 
		}		
	}
}

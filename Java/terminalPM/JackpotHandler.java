package terminalPM;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Random;
import java.util.concurrent.TimeUnit;

public class JackpotHandler {

	private static final String DIAMONDS = "\u2666";
	private static final String CLUBS = "\u2663";
	private static final String SPADES = "\u2660";	
	
	private Connection dbConnection;
	private int userID;
	
	public JackpotHandler(Connection c, int u) {
		
		this.dbConnection = c;
		this.userID = u;
		
		launch();
	}
	
	private void launch() {
	
		String s1 = generateRandomSymbol(), s2 = generateRandomSymbol(), s3 = generateRandomSymbol();
		
		System.out.println("\nGenerating symbols...\n");
		try {
			TimeUnit.SECONDS.sleep(2);
			System.out.print(s1);
			
			TimeUnit.SECONDS.sleep(2);
			System.out.print(s2);
			
			TimeUnit.SECONDS.sleep(2);
			System.out.print(s3);
		}
		catch (InterruptedException e) {
			e.printStackTrace();
		}
		System.out.println("\n");
		
		if( !s1.equals(s2) || !s1.equals(s3) ) {
			System.out.println("Pas de chance, ...");
			return;
		}
		
		
	}
	
	private int collectJackpot() {
		
		try {
			
			PreparedStatement ps = dbConnection.prepareStatement("");
			ps.setInt(1, userID);
			ResultSet rs = ps.executeQuery();
		}
		catch(SQLException e) {
			e.printStackTrace();
		}
		
		return -1;
	}
	
	private String generateRandomSymbol() {

	    int randomNum = (new Random()).nextInt(3)+1;

	    if( randomNum == 1 )
	    	return DIAMONDS;
	    	
	    if( randomNum == 2 )
	    	return CLUBS;
	    
	    return SPADES;
	}

}

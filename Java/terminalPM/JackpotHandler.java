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
	
	public JackpotHandler(Connection connection, int userID) {
		
		this.dbConnection = connection;
		this.userID = userID;
		
		launch();
	}
		
	private void launch() {
			
		System.out.println("\nJackPot");
		System.out.println("-------\n");
		
		System.out.println("Si les 3 symboles correspondent,\nvous gagnez une vie supplementaire.");
		System.out.println("Uniquement valable 5min. apres un combat.\n");
		
		boolean jackpotResult = this.runJackpot();
		
		if( jackpotResult == false ) {
			System.out.println("\n\nDesole, vous ne gagnez rien...");
			return;
		}
		
		int currentLives = collectJackpot();
		
		if(currentLives != -1) {
			
			System.out.println("\nBingo, vous gagnez une vie supplementaire.");
			System.out.println("Vous avez donc maintenant "+currentLives+" vies.\n");
			
			for(int i=0; i<currentLives; i++) 
				System.out.print(LoginHandler.HEARTICON +" ");
		}
		
		System.out.println("");
	}
	
	private boolean runJackpot() {
		
		String s1 = generateRandomSymbol(), s2 = generateRandomSymbol(), s3 = generateRandomSymbol();

		try {
			TimeUnit.SECONDS.sleep(1);
			System.out.print(s1);
			
			TimeUnit.SECONDS.sleep(1);
			System.out.print(s2);
			
			TimeUnit.SECONDS.sleep(1);
			System.out.print(s3);
			
			TimeUnit.SECONDS.sleep(1);
		}
		catch (InterruptedException e) {
			e.printStackTrace();
		}
		
		return ( s1.equals(s2) && s1.equals(s3) );
	}
	
	private int collectJackpot() {
		
		try {
			
			PreparedStatement ps = dbConnection.prepareStatement("SELECT * FROM projet.encaisser_jackpot(?);");
			ps.setInt(1, userID);
			ResultSet rs = ps.executeQuery();
			rs.next();
			
			return rs.getInt(1);
		}
		catch(SQLException e) {
			System.out.println(e.getMessage());
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

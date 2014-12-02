
package terminalPM;

import java.sql.*;
import java.util.Scanner;

public class App {
	
	private static final String USER = "corentin";
	private static final String PASS = "password";
	private static Scanner scan = new Scanner(System.in);
	
	@SuppressWarnings("unused")
	private Connection dbConnection;
	
	public App() {
		
		super();
		dbConnect();
		
		if( !loginAttempt(3) ) {
			System.out.println("Exceed number of trials");
			System.exit(1);
		}
		
		displayMenu();
	}


	private void dbConnect() {
		
		try {
			Class.forName("org.postgresql.Driver");
		}
		catch(Exception e) {	
			System.out.println("Driver missing");
			System.exit(1);
		}
	
		String url="jdbc:postgresql://localhost/pubs2?user="+ USER +"&password="+ PASS;
		
		try {
			this.dbConnection = DriverManager.getConnection(url);
		} 
		catch (SQLException e) {
			System.out.println("Server unreachable");
			System.exit(1);
		}
	}	
	
	private boolean loginAttempt(int nbAttempts) {
		
		// Retrieve password
		// For dev, this is the hash of 'password'
		String storedPass = "e563d80a8104bd37c5757056d4fd24e516ac0a65e450607a75cc0bd13b1e5678297afe756cf368e7d4a94bb940497f59513f5ae4f5663f4b3f68fa4b9b700ba6";
		
		while(nbAttempts > 0) {
			
			System.out.println("Enter password ("+nbAttempts+" attemps) :");
			String tempPass = scan.next();
			
			if( CryptService.hash(tempPass) == storedPass )
				return true;
			
			nbAttempts--;
		}
		
		return false;
	}
	
	private void displayMenu() {
		
		System.out.println("Terminal Power Mangeur");
		System.out.println("----------------------\n");
	}
	
	/*private void getInformations() {

		try {
			// Exectution pour mise a jour
			// !! ATTENTION AUX INJECTIONS SQL !! --> Utiliser PreparedStatement (slides)
			Statement s = this.dbConnection.createStatement();
			s.executeUpdate("INSERT INTO exercice.utilisateurs VALUES (DEFAULT, 'Doe', 'John');");
			
			// Execution pour select
			@SuppressWarnings("unused")
			Statement s2 = this.dbConnection.createStatement();
			ResultSet rs = s.executeQuery("SELECT...");
			
			// getMetaData() pour infos sur resultset
			rs.getMetaData().getColumnCount();
			
			// Next() avance curseur et retourne FALSE a la fin
			while( rs.next() ) {
				System.out.println( rs.getString(1) );
			}
			// !! NE JAMAIS UTILISER DE STATEMENT --> PreparedStatement !!			
		}
		catch (SQLException e) {
			e.printStackTrace();
			System.exit(1);
		}
	}*/

	public static void main(String[] args) {
		
		new App();
	}

}

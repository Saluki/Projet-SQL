package terminalPM;

import java.sql.*;
import java.util.Scanner;

public class LoginHandler {
	
	private Connection dbConnection;
	private int userID;
	private Scanner scan;
	
	public LoginHandler(Connection c) {
		
		this.dbConnection = c;
		this.scan = new Scanner(System.in);
	}
	
	public int login() {
		
		System.out.println("\nIdentification required");
		System.out.println("-----------------------\n");
		
		String storedPass = null;
		while( storedPass == null ) {
			
			System.out.print("Name: ");
			String name = scan.next();
			
			storedPass = retrievePassword(name);
		}
		
		while(true) {
			
			System.out.print("\nPassword: ");
			String tempPass = scan.next();
			
			String hash = CryptService.hash(tempPass);
			
			if( storedPass != null && hash.equals(storedPass) )
				break;
			
			System.out.println("Sorry, retry");
		}
		
		System.out.println("Correct password");
		
		return this.userID;
	}
	
	private String retrievePassword(String name) {
		
		if( name == null || name == "" )
			return null;
				
		try {
			
			PreparedStatement ps = dbConnection.prepareStatement("SELECT * FROM projet.power_mangeurs WHERE nom=?;");
			ps.setString(1, name);
			ResultSet r = ps.executeQuery();
			
			if( r.next() ) {
				
				this.userID = r.getInt("id_pm");
				return r.getString("mot_de_passe");
			}
		}
		catch(SQLException e) {
			e.printStackTrace();
		}
		
		return null;
	}

}

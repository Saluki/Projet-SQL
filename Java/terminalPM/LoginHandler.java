package terminalPM;

import java.sql.*;
import java.util.Scanner;

public class LoginHandler {
	
	private Connection dbConnection;
	private Scanner scan;
	
	public LoginHandler(Connection c) {
		
		this.dbConnection = c;
		this.scan = new Scanner(System.in);
	}
	
	public boolean login() {
		
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
			
			System.out.println("Sorry, try again");
		}
		
		System.out.println("Correct password");
		return true;
	}
	
	private String retrievePassword(String name) {
		
		if( name == null || name == "" )
			return null;
				
		try {
			
			PreparedStatement ps = dbConnection.prepareStatement("SELECT mot_de_passe FROM projet.power_mangeurs WHERE nom=?;");
			ps.setString(1, name);
			ResultSet r = ps.executeQuery();
			
			if( r.next() )
				return r.getString(1);
		}
		catch(SQLException e) {
			e.printStackTrace();
		}
		
		return null;
	}

}

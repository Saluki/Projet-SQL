package terminalPM;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Scanner;

public class LoginHandler {
	
	public static final String HEARTICON = "\u2764";
	
	private Connection dbConnection;
	private Scanner scan;
	
	private int userID;
	private String hashedPassword;
	private int lives;
	
	public LoginHandler(Connection c) {
		
		this.dbConnection = c;
		this.scan = new Scanner(System.in);
	}
	
	public int login() {
		
		System.out.println("\nIdentification requise");
		System.out.println("----------------------\n");
		
		while( this.userID == 0 || this.lives <= 0 ) {
			
			System.out.print("Nom: ");
			String name = scan.next();
			
			retrieveUserDate(name);
			
			if( this.userID == 0 || this.lives == 0 )
				System.out.println("Desole, ce Power Mangeur est mort ou n'existe pas\n");
		}
		
		while(true) {
			
			System.out.print("\nMot de passe: ");
			String tempPass = scan.next();
			
			String hash = CryptService.hash(tempPass);
			
			if( hashedPassword != null && hash.equals(hashedPassword) )
				break;
			
			System.out.println("Desole, mot de passe incorrect");
		}
		
		System.out.println("Mot de passe correct");
		
		System.out.print("\nVies : ");
		for(int i=0; i<this.lives; i++)
			System.out.print(HEARTICON +" ");
		System.out.println("");
		
		return this.userID;
	}
	
	private void retrieveUserDate(String name) {
		
		if( name == null || name == "" )
			return;
				
		try {
			
			PreparedStatement ps = dbConnection.prepareStatement("SELECT * FROM projet.power_mangeurs WHERE nom=?;");
			ps.setString(1, name);
			ResultSet r = ps.executeQuery();
			
			if( r.next() ) {
				
				this.userID = r.getInt("id_pm");
				this.hashedPassword = r.getString("mot_de_passe");
				this.lives = r.getInt("vie");
			}
		}
		catch(SQLException e) {
			e.printStackTrace();
		}
	}

}

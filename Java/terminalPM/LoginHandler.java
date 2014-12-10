package terminalPM;

import java.math.BigInteger;
import java.security.GeneralSecurityException;
import java.security.InvalidParameterException;
import java.sql.*;
import java.util.Scanner;

import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;

public class LoginHandler {
	
	private static final int ITERATIONS = 1000;
	private static final String SALT = "FE26EEE87B528135";
	private static final int KEYLENGTH = 64*8;
	private static final String CIPHER = "PBKDF2WithHmacSHA1";
	
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
			
			String hash = this.hash(tempPass);
			
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
	
	public String hash(String s) {
		
		if( s == null ) throw new InvalidParameterException();
				
		PBEKeySpec spec = new PBEKeySpec(s.toCharArray(), SALT.getBytes(), ITERATIONS, KEYLENGTH);
		
		byte[] hash;
		try {
			hash = SecretKeyFactory.getInstance(CIPHER).generateSecret(spec).getEncoded();			
		}
		catch(GeneralSecurityException e) { return null; }
		
		return toHex( hash );
	}
	
	private String toHex(byte[] array)
    {
        String hex = ( new BigInteger(1, array) ).toString(16);
        int paddingLength = (array.length * 2) - hex.length();
        
        if(paddingLength > 0)
        	return String.format("%0"  +paddingLength + "d", 0) + hex;
        
        return hex;
    }

}

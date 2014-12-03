
package terminalPM;

import java.sql.*;
import java.util.Scanner;

public class App {
	
	private static final String USER = "corentin";
	private static final String PASS = "password";
	private static final String DBNAME = "IPL";
	
	private static Scanner scan = new Scanner(System.in);
	
	private Connection dbConnection;
	
	public App() {
		
		dbConnect();
		
		( new LoginHandler(dbConnection) ).login();
		
		showMenu();
	}

	private void dbConnect() {
		
		try {
			Class.forName("org.postgresql.Driver");
		}
		catch(Exception e) {	
			System.out.println("Driver missing");
			System.exit(1);
		}
	
		String url="jdbc:postgresql://localhost/"+ DBNAME +"?user="+ USER +"&password="+ PASS;
		
		try {
			this.dbConnection = DriverManager.getConnection(url);
		} 
		catch (SQLException e) {
			System.out.println("Server unreachable");
			System.exit(1);
		}
	}	
	
	private void showMenu() {
		
		System.out.println("\nTerminal Power Mangeur");
		System.out.println("----------------------\n");
		
		System.out.println("#1\tPOWER MANGEUR ACTIVATION!");
		System.out.println("#2\tHistorique dernier combat");
		System.out.println("#3\tStatistiques");
		System.out.println("#4\tQuitter");

	}

	public static void main(String[] args) {
		
		new App();
	}

}

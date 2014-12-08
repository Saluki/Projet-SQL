
package terminalPM;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Scanner;

public class App {
		
	private static final String SERVER = "localhost";
	private static final String USER = "corentin";
	private static final String PASS = "password";
	private static final String DBNAME = "IPL";
	
	private static Scanner scan = new Scanner(System.in);
	
	private Connection dbConnection;
	private int userID;
	
	public App() {
		
		dbConnect();
		
		userID = ( new LoginHandler(dbConnection) ).login();
		
		restartBattle();
		
		int selectedAction = showMenu();
		while( selectedAction != 0 ) {
			
			executeAction(selectedAction);
			selectedAction = showMenu();
		}
		
		closeApp();
	}

	/**
	 * Tente d'etablir une connexion a la base de donnees
	 * 
	 * Avant d'etablir la connexion, un controle est effectue pour voir si le 
	 * driver PostreSQL est bien installe.
	 * Si la connection est effectuee, elle est persistee dans l'attribut 
	 * dbConnection de la classe App. Sinon, en cas d'erreur, le programme est 
	 * interrompu directement en terminant avec un code de retour 1.
	 * 
	 * @return	void
	 */
	private void dbConnect() {
		
		try {
			Class.forName("org.postgresql.Driver");
		}
		catch(Exception e) {	
			System.out.println("Module PostgreSQL manquant");
			System.exit(1);
		}
	
		String url="jdbc:postgresql://"+SERVER+"/"+ DBNAME +"?user="+ USER +"&password="+ PASS;
		
		try {
			this.dbConnection = DriverManager.getConnection(url);
		} 
		catch (SQLException e) {
			System.out.println("Le serveur distant ne reponds pas");
			System.exit(1);
		}
	}	
	
	/**
	 * Relance le dernier combat en cours
	 * 
	 * Un controle est effectue pour voir si le Power Mangeur possede encore 
	 * un combat qui n'est pas termine (qui n'a pas encore de date de fin).
	 * Si c'est le cas, une bataille est lancee avec les informations de la bataille 
	 * qui n'etait pas terminee. Sinon, si tous les combats sont acheves, 
	 * une simple notification est affichee.
	 * 
	 * @return	void
	 */
	private void restartBattle() {
		
		try {
			
			PreparedStatement ps = dbConnection.prepareStatement("SELECT id_combat FROM projet.combats WHERE id_pm=? AND date_fin IS NULL");
			ps.setInt(1, this.userID);
			ResultSet rs = ps.executeQuery();
			
			if( rs.next() )
				new BattleHandler(dbConnection, rs.getInt("id_combat") );
			else
				System.out.println("\n[INFO] Aucun combat ouvert");
			
		} catch (SQLException e) { e.printStackTrace(); }
	}
	
	private int showMenu() {
		
		System.out.println("\nTerminal Power Mangeur");
		System.out.println("----------------------\n");
		
		System.out.println("#1\tPOWER MANGEUR ACTIVATION!");
		System.out.println("#2\tHistorique dernier combat");
		System.out.println("#3\tStatistiques");
		System.out.println("#0\tQuitter");
		
		System.out.print("\nChoix: ");
		
		return scan.nextInt();
	}
	
	private void executeAction(int action) {
		
		if( action==1 ) {
			new BattleHandler(dbConnection);
		}
		else if( action==2 ) {
			new HistoryHandler(dbConnection, userID);
		}
		else if( action==3 ) {
			new StatsHandler(dbConnection);
		}
	}
	
	private void closeApp() {
		
		System.out.println("\nGoodbye...");
	}

	public static void main(String[] args) {
		
		new App();
	}

}

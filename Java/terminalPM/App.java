
package terminalPM;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Scanner;

/**
 * Lance un terminal pour les Power Mangeurs
 * 
 * Ce terminal, apres s'etre connecte au serveur, permettra au Power Mangeur de 
 * lancer ou continuer un combat, de voir le deroulement de son dernier combat 
 * et de visualiser des statistiques concernant ses combats. 
 */
public class App {
		
	private static final String SERVER = "localhost";
	private static final String USER = "corentin";
	private static final String PASS = "password";
	private static final String DBNAME = "IPL";
	
	private static final int CLOSE_ACTION = 0;
	private static final int BATTLE_ACTION = 1;
	private static final int HISTORY_ACTION = 2;
	private static final int STATS_ACTION = 3;
	private static final int JACKPOT_ACTION = 4;
	
	private static Scanner scanner = new Scanner(System.in);
	
	private Connection dbConnection;
	private int userID;
	
	/**
	 * Construit l'application et dirige son comportement
	 * 
	 * Cette methode controle toute l'execution de l'application, de la connection
	 * au serveur de bases de donnees PostgreSQL jusqu'a la fermeture de l'application.
	 * Ceci est le déroulement classique de l'application: 
	 * - Connection au serveur
	 * - Identification du Power Mangeur
	 * - Eventuellement continuer une bataille qui était en cours
	 * - Montrer le menu principal et executer autant d'actions que le Power Mangeur souhaitera
	 * - Fermer l'application
	 */
	public App() {
		
		databaseConnect();
		
		userID = ( new LoginHandler(dbConnection) ).login();
		
		try {
			restartLastBattle();
			
			int selectedAction = showMenu();
			
			while( selectedAction != CLOSE_ACTION ) {
				
				executeAction(selectedAction);
				selectedAction = showMenu();
			}
		}
		catch(DeadException e) {
			System.out.println("\nDesole, tu viens de mourir...");
			System.out.println("Tu ne pourras donc plus te connecter a ce terminal.");
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
	private void databaseConnect() {
		
		try {
			Class.forName("org.postgresql.Driver");
		}
		catch(ClassNotFoundException e) {	
			System.out.println("Module PostgreSQL manquant");
			System.exit(1);
		}
	
		String databaseUrl="jdbc:postgresql://"+SERVER+"/"+ DBNAME +"?user="+ USER +"&password="+ PASS;
		
		try {
			this.dbConnection = DriverManager.getConnection(databaseUrl);
		} 
		catch (SQLException e) {
			System.out.println("Serveur PostgreSQL distant ne reponds pas");
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
	private void restartLastBattle() throws DeadException {
		
		try {
			
			PreparedStatement ps = dbConnection.prepareStatement("SELECT id_combat FROM projet.combats WHERE id_pm=? AND date_fin IS NULL");
			ps.setInt(1, this.userID);
			ResultSet rs = ps.executeQuery();
			
			if( !rs.next() )
				return;
			
			System.out.println("\nRecuperation du combat precedent en cours...");
			new BattleHandler(dbConnection, userID, rs.getInt("id_combat") );
		} 
		catch (SQLException e) { 
			e.printStackTrace(); 
		}
	}
	
	/**
	 * Affiche le menu principal de l'application
	 * 
	 * Cette methode a pour seul but d'afficher le menu principal de l'application 
	 * ainsi que de renvoyer le numero de l'action choisi par l'utilisateur.
	 * Il n'y a pas de controle pour regarder si le numero correspond bien a une action.
	 * 
	 * @return	int		Numero de l'action
	 */
	private int showMenu() {
		
		System.out.println("\nTerminal Power Mangeur");
		System.out.println("----------------------\n");
		
		System.out.println("#"+ BATTLE_ACTION +"\tPOWER MANGEUR ACTIVATION!");
		System.out.println("#"+ HISTORY_ACTION +"\tHistorique dernier combat");
		System.out.println("#"+ STATS_ACTION +"\tStatistiques");
		System.out.println("#"+ JACKPOT_ACTION +"\tJackpot");
		System.out.println("#"+ CLOSE_ACTION +"\tQuitter");
		
		System.out.print("\nChoix: ");
		
		return scanner.nextInt();	    
	}
	
	/**
	 * Execute une action specifique
	 * 
	 * Execute l'action dont le numero est passe en parametre. Si le numero 
	 * n'est pas lie a une action, la methode ne fera rien.
	 * Les actions disponibles sont: 
	 * - Lancement d'un nouveau combat [1]
	 * - Affichage de l'historique d'un combat [2]	
	 * - Lancement du menu statistiques [3]
	 * 
	 * @param	action	Un numéro correspondant a une action
	 * @return	void
	 * @throws	DeadException 
	 */
	private void executeAction(int action) throws DeadException {
		
		if(action == BATTLE_ACTION) {
			new BattleHandler(dbConnection, userID);
		}
		else if(action == HISTORY_ACTION) {
			new HistoryHandler(dbConnection, userID);
		}
		else if(action == STATS_ACTION) {
			new StatsHandler(dbConnection, userID);
		}
		else if(action == JACKPOT_ACTION) {
			new JackpotHandler(dbConnection, userID);
		}
	}
	
	/**
	 * Ferme l'application
	 * 
	 * Coupe la connection au serveur de bases de donnees et termine l'application en 
	 * renvoyant un code 0 pour signifier que l'application s'est fermee sans problemes.
	 * En cas de problemes lors de deconnection au serveur, l'application se terminera 
	 * avec un code 1.
	 * 
	 * @return	void
	 */
	private void closeApp() {
		
		try {
			this.dbConnection.close();
		} 
		catch (SQLException e) {
			System.exit(1);
		}
		
		System.out.println("\nFermeture de l'application...");
		System.exit(0);
	}

	// LANCEMENT DE L'APPLICATION POWER-MANGEURS
	
	public static void main(String[] args) {
		
		new App();
	}

}

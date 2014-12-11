package terminalPM;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Date;
import java.util.Scanner;

public class BattleHandler {
	
	private static final int BATTLETIME = 10;
	
	private static Scanner scan = new Scanner(System.in);
	
	private Connection dbConnection;
	
	private int userID;
	
	private int battleID;
	private long beginTimestamp;
	
	private int monsterID;
	private String monsterName;
	private int monsterPower;
	
	public BattleHandler(Connection c, int userID) throws DeadException {
		
		this.dbConnection = c;
		this.userID = userID;
		
		if( setRandomMonster() == false ) {
			System.out.println("Yeah, aucun monstre a combattre pour l'instant...");
			return;
		}
				
		if( startNewBattle() == false ) {
			System.out.println("Impossible de commencer un combat\nUn combat est peut-etre deja en cours...");
			return;
		}		
		
		executeBattle();
	}
	
	public BattleHandler(Connection c, int userID, int idCombat) throws DeadException {
		
		this.dbConnection = c;
		this.userID = userID;
		this.battleID = idCombat;
		
		try {
			PreparedStatement ps = dbConnection.prepareStatement("SELECT * FROM projet.combats WHERE id_combat=? AND date_fin IS NULL");
			ps.setInt(1, battleID);
			ResultSet rs = ps.executeQuery();
			
			if( !rs.next() )
				return;
			
			this.beginTimestamp = (rs.getTimestamp("date_debut")).getTime();
			this.monsterID = rs.getInt("id_archetype");
		}
		catch(SQLException e) { 
			e.printStackTrace();
			return;
		}
		
		if( isTimeOver() ) {
			closeBattle(true);
			return;
		}
		
		executeBattle();
	}
	
	private void executeBattle() throws DeadException {
		
		int choice = -1;
		while(choice != 1) {
			
			choice = displayMainMenu();
			
			if( isTimeOver() ) {
				this.closeBattle(true);
				return;
			}
				
			if( choice == 2 ) {
				this.usePowerUp();
			}
		}
		this.closeBattle(false);
		
		if( this.isDead() )
			throw new DeadException();
	}
	
	private boolean isTimeOver() {
		
		long diff = ( (new Date()).getTime() - this.beginTimestamp )/1000;
		return ( diff > BATTLETIME*60 );
	}
	
	private boolean setRandomMonster() {
		
		try {
			
			PreparedStatement ps = dbConnection.prepareStatement("SELECT * FROM projet.monstre_au_hasard");
			ResultSet rs = ps.executeQuery();
			
			if( !rs.next() )
				return false;
			
			this.monsterID = rs.getInt("id_archetype");
			this.monsterName = rs.getString("nom");
			this.monsterPower = rs.getInt("puissance");
			
			System.out.println("\nLancement d'un combat contre...\nun monstre "+monsterName+" avec puissance "+monsterPower+"!");
		}
		catch(SQLException e) { 
			
			e.printStackTrace();
			return false;
		}
		
		return true;
	}
	
	private boolean startNewBattle() {
		
		try {
			PreparedStatement ps = dbConnection.prepareStatement("SELECT * FROM projet.debuter_combat(?,?)");
			ps.setInt(1, this.userID);
			ps.setInt(2, this.monsterID);
			ResultSet rs = ps.executeQuery();
			
			rs.next();
			this.battleID = rs.getInt(1);
			this.beginTimestamp = ( new Date() ).getTime();
			
			System.out.println("\nDebut des hostilites...");
		}
		catch(SQLException e) {

			return false;
		}
		
		return true;
	}

	private int displayMainMenu() {
		
		System.out.println("\nMenu Combat");
		System.out.println("-----------\n");
		
		System.out.println("#1\tConclure combat");
		System.out.println("#2\tUtiliser Power-Up");
		
		System.out.println("\nChoix :");
		return scan.nextInt();
	}
	
	private void closeBattle(boolean force) {
		
		if( force ) {
			System.out.println("\nDuree maximale du combat depassee!");
		}
		
		try {
			PreparedStatement ps = dbConnection.prepareStatement("SELECT * FROM projet.conclure_combat(?)");
			ps.setInt(1, userID);
			ResultSet rs = ps.executeQuery();
			
			rs.next();
			
			if( rs.getBoolean(1) == true )
				System.out.println("\nLe combat est GAGNE!");
			else
				System.out.println("\nLe combat est PERDU...");
		}
		catch(SQLException e) {
			
			e.printStackTrace();
			System.out.println("Probleme survenu lors de la cloture du combat");
		}
	}
	
	private void usePowerUp() {
		
		System.out.println("\nChoisir un Power-Up");
		System.out.println("-------------------\n");
				
		try {
			PreparedStatement ps = dbConnection.prepareStatement("SELECT * FROM projet.power_ups WHERE id_pm = ?");
			ps.setInt(1, userID);
			ResultSet rs = ps.executeQuery();
			
			while( rs.next() ) {
				
				int ID = rs.getInt("id_pu");
				String name = rs.getString("nom");
				
				System.out.println("#"+ID+"\t"+name);
			}
			
			int choice = scan.nextInt();
			
			ps = dbConnection.prepareStatement("SELECT * FROM projet.utiliser_pu(?, ?)");
			ps.setInt(1, userID);
			ps.setInt(2, choice);
			rs = ps.executeQuery();			
		}
		catch(SQLException e) {
			
			System.out.println("\n"+ e.getMessage() );
		}
	}
	
	private boolean isDead() {
		
		try {
			
			PreparedStatement ps = dbConnection.prepareStatement("SELECT vie FROM projet.power_mangeurs WHERE id_pm = ?");
			ps.setInt(1, userID);
			ResultSet rs = ps.executeQuery();
			
			if( !rs.next() || rs.getInt(1) <= 0 )
				return true;
		}
		catch(SQLException e) {
			
			e.printStackTrace();
		}
		
		return false;
	}
}

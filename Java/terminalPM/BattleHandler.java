package terminalPM;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class BattleHandler {
	
	private Connection dbConnection;
	
	// Informations sur le combat en cours
	private int idCombat;
	private int idArchetype;
	private int dateDebut;
	
	public BattleHandler(Connection c) {
		
		this.dbConnection = c;
		
		if( setRandomMonster() == false ) {
			System.out.println("Yeah, aucun monstre a combattre pour l'instant...");
			return;
		}
		
		startBattle();
	}
	
	public BattleHandler(Connection c, int idCombat) {
		
		this.dbConnection = c;
		
		/*try {
			PreparedStatement ps = dbConnection.prepareStatement("SELECT id_combat FROM projet.combats WHERE id_combat=?");
			ps.setInt(1, idCombat);
			ResultSet rs = ps.executeQuery();
			
			if( !rs.next() )
				return;
			
			rs.getString(arg0)
		}
		catch(SQLException e) { e.printStackTrace(); }*/
	}
	
	private void startBattle() {
		
		System.out.println("Beginning battle...");
	}

	private boolean setRandomMonster() {
		
		try {
			
			PreparedStatement ps = dbConnection.prepareStatement("SELECT * FROM projet.monstre_au_hasard");
			ResultSet rs = ps.executeQuery();
			
			if( rs.next() ) {
				// Ajout monstre
			} 
			else {
				System.out.println("Yeah, aucun monstre a combattre pour l'instant...");
				return false;
			}
		}
		catch(SQLException e) { e.printStackTrace(); }
		
		return true;
	}

}

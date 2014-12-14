package terminalPM;

import java.sql.*;
import java.util.Scanner;

public class StatsHandler {
	
	private Connection dbConnection;
	private int userID;
	private Scanner scanner = new Scanner(System.in);
	
	public StatsHandler(Connection c, int ID) {
		
		this.dbConnection = c;
		this.userID = ID;

		launch();
	}

	private void launch() {
		
		int action = -1;
		
		while( action != 0 ) {
			
			action = this.showMenu();
			
			System.out.println("");
			
			if( action == 1 )
				showStatsMonster();
			
			else if( action == 2 )
				showStatsLife();
			
			else if( action == 3 )
				showPowerUpHistory();
			
			else if( action != 0 )
				System.out.println("Cette option n'existe pas");
		}
	}
	
	/**
	 * Affiche le menu des statistiques
	 * 
	 * @return	int		L'identifiant de l'action choisie
	 */
	private int showMenu() {
		
		System.out.println("\nStatistiques");
		System.out.println("------------\n");
		
		System.out.println("#1\tStatistiques des combats");
		System.out.println("#2\tEsperance de vie");
		System.out.println("#3\tHistorique Power Ups");
		System.out.println("#0\tRetour");
		
		System.out.print("\nChoix: ");
		
		return scanner.nextInt();			
	}
	
	/**
	 * Affiche les statistiques sur le nombre de combats
	 * 
	 * @return	void
	 */
	private void showStatsMonster() {
		
		System.out.println("\nStatistiques des combats");
		System.out.println("------------------------\n");
		
		try {
			PreparedStatement ps = dbConnection.prepareStatement("SELECT * FROM projet.stats_pm(?)");
			ps.setInt(1, userID);
			ResultSet rs = ps.executeQuery();
			
			if( !rs.next() ) {
				System.out.println("Aucune statistique disponible");
				return;
			}
			
			do {
				
				System.out.println("- Monstre "+ rs.getString("nom_archetype") );
				System.out.println("\t- Total combats\t\t"+ rs.getInt("nb_combats_total") );
				System.out.println("\t- Total victoires\t"+ rs.getInt("nb_victoires_total") );
				System.out.println("\t- Combats annee\t\t"+ rs.getInt("nb_combats_annee") );
				System.out.println("\t- Victoires annee\t"+ rs.getInt("nb_victoires_annee") );
			}
			while( rs.next() );
		} 
		catch (SQLException e) {
			e.printStackTrace();
		}
	}
	
	/**
	 * Affiche l'esperance de vie du Power Mangeur
	 * 
	 * L'esperance de vie est calculee...
	 * 
	 * @return	void
	 */
	private void showStatsLife() {
		
		System.out.println("\nEsperance de vie");
		System.out.println("----------------\n");
		
		try {
			PreparedStatement ps = dbConnection.prepareStatement("SELECT * FROM projet.esperance_vie(?)");
			ps.setInt(1, userID);
			ResultSet rs = ps.executeQuery();		
			rs.next();
			
			String e = rs.getString("esperance_vie");
			
			if( e.equals("00:00:00") )
				System.out.println("Esperance de vie indeterminee");
			else
				System.out.println( rs.getString("esperance_vie") );
		} 
		catch (SQLException e) {
			e.printStackTrace();
		}
	}
	
	
	private void showPowerUpHistory() {
		
		System.out.println("\nHistorique des Power Up");
		System.out.println("-----------------------\n");
		
		try {
			PreparedStatement ps = dbConnection.prepareStatement("SELECT * FROM projet.historique_pu WHERE id_pm = ?;");
			ps.setInt(1, userID);
			ResultSet rs = ps.executeQuery();
			
			if( !rs.next() ) {
				System.out.println("Aucun historique d'utilisation de Power Up");
				return;
			}
			
			do {
				
				String name = rs.getString("nom");
				int f = rs.getInt("facteur");
				Timestamp timestamp = rs.getTimestamp("date_utilisation");
				
				System.out.println(name +"  [+"+ f +"%]  "+ timestamp);
			}
			while( rs.next() );
		}
		catch(SQLException e) {
			e.printStackTrace();
		}
	}

}

import java.sql.*;
import java.util.ArrayList;
import java.util.Scanner;

public class Terminal {

    // A remplacer !!!
    private static final String DB_HOST = "localhost";
    private static final String DB_NAME = "postgres";
    private static final String DB_USER = "postgres";
    private static final String DB_PWD = "postgres";

    private static Scanner scan;
    private static Connection db;
    private static ArrayList<PreparedStatement> statements;

    private static byte choix = -1;

    public static void main(String[] args) {

        try {
            Class.forName("org.postgresql.Driver");
        } catch (ClassNotFoundException e) {
            System.out.println("Driver PostgreSQL manquant !");
            System.exit(1);
        }

        try {
            db = DriverManager.getConnection("jdbc:postgresql://"+DB_HOST+"/"+DB_NAME+"?user="+DB_USER+"&password="+DB_PWD);
        } catch (SQLException e) {
            System.out.println("Impossible de joindre le server !");
            System.exit(1);
        }

        try {
            statements = new ArrayList<PreparedStatement>(7);
            statements.add(null);
            statements.add(db.prepareStatement("SELECT projet.inscrire_pm(?, ?, ?);"));
            statements.add(db.prepareStatement("SELECT projet.ajouter_archetype(?, ?);"));
            statements.add(db.prepareStatement("SELECT projet.attribuer_pu(?, ?, ?);"));
            statements.add(db.prepareStatement("SELECT * FROM projet.classement_pm;"));
            statements.add(db.prepareStatement("SELECT * FROM projet.liste_decedes"));
            statements.add(db.prepareStatement("SELECT * FROM projet.historique_combats WHERE nom_pm = ? AND date_debut BETWEEN ? AND ?"));
        } catch (SQLException e) {
            System.out.println("Problème de requête préparée !");
            e.printStackTrace();
            System.exit(1);
        }

        scan = new Scanner(System.in);

        launch();

        try {
            scan.close();
            db.close();
//            System.out.println("Fermeture de la connexion à la BDD réussie.");
        } catch (SQLException e) {
            System.out.println("Fermeture de la connexion à la BDD échouée.");
        } finally {
            System.out.println("Au revoir !");
        }

    }

    public static void launch () {

        System.out.println("Bienvenue Toriko");
        System.out.println("----------------");

        afficherMenu();

        while (choix != 0) {

            System.out.print("\nCommande ");

            try {
                choix = scan.nextByte();
            } catch (Exception e) {
                choix = -1;
            }

            switch (choix) {
                case 0:
                    break;
                case 1:
                    inscrire_pm();
                    break;
                case 2:
                    ajouter_monstre();
                    break;
                case 3:
                    attribuer_pu();
                    break;
                case 4:
                    classement_pm();
                    break;
                case 5:
                    liste_deces();
                    break;
                case 6:
                    historique_combats();
                    break;
                default:
                    System.out.println("Ceci n'est pas une commande valide.");
                    afficherMenu();
                    break;
            }

        }

    }

    private static void afficherMenu() {
        System.out.println("\nAide");
        System.out.println(" --------------------------------------------------- ");
        System.out.println("| 1 | Inscription d'un Power Mangeur                |");
        System.out.println("| 2 | Ajout d'un archétype                          |");
        System.out.println("| 3 | Attribution d'un Power-Up                     |");
        System.out.println("| 4 | Classement des Power Mangeurs                 |");
        System.out.println("| 5 | Liste des Power Mangeurs décédés cette année  |");
        System.out.println("| 6 | Historique des combats d'un Power Mangeur     |");
        System.out.println(" ---------------------------------------------------");
        System.out.println("| 0 | Quitter l'application                         |");
        System.out.println(" ---------------------------------------------------");
    }

    private static void inscrire_pm() {

        System.out.println("\nInscription d'un Power Mangeur");
        System.out.println("------------------------------\n");

        String nom, mdp, couleur;
        PreparedStatement statement = statements.get(choix);

        try {
            System.out.print("Nom : ");
            try {
                nom = scan.next();
            } catch (Exception e) {
                System.out.println("Problème d'input.");
                return;
            }
            statement.setString(1, nom);

            System.out.print("Couleur : ");
            try {
                couleur = scan.next();
            } catch (Exception e) {
                System.out.println("Problème d'input.");
                return;
            }
            statement.setString(2, couleur);

            System.out.print("Mot de passe : ");
            try {
                mdp = scan.next();
            } catch (Exception e) {
                System.out.println("Problème d'input.");
                return;
            }
            statement.setString(3, mdp);

        } catch (SQLException e) {
            System.out.println("Erreur avec la base de données.");
            System.exit(1);
        }

        System.out.println("Inscription du PM en cours...");
        try {
            statement.execute();
//            ResultSet result = statement.executeQuery();
//            int id_pm = result.getInt(1);
            System.out.println("Inscription réussie !");
        } catch (SQLException e) {
            System.out.println("Problème à l'inscription !");
            System.out.println(e.getMessage());
        }

    }

    private static void ajouter_monstre () {

        System.out.println("\nAjout d'un archétype de monstro-nourriture");
        System.out.println("------------------------------------------\n");

        String nom;
        int facteur;
        PreparedStatement statement = statements.get(choix);

        try {
            System.out.print("Nom : ");
            try {
                nom = scan.next();
            } catch (Exception e) {
                System.out.println("Problème d'input.");
                return;
            }
            statement.setString(1, nom);

            System.out.print("Facteur : ");
            try {
                facteur = scan.nextInt();
            } catch (Exception e) {
                System.out.println("Problème d'input.");
                return;
            }
            statement.setInt(2, facteur);

        } catch (SQLException e) {
            System.out.println("Erreur avec la base de données.");
            System.exit(1);
        }

        System.out.println("Ajout de l'archétype en cours...");
        try {
            statement.execute();
            System.out.println("Ajout réussi !");
        } catch (SQLException e) {
            System.out.println("Problème à l'ajout !");
            System.out.println(e.getMessage());
        }
    }

    private static void attribuer_pu () {

        System.out.println("\nCréation d'un Power-Up");
        System.out.println("----------------------\n");

        String nom_pu, nom_pm;
        int facteur_pu;
        PreparedStatement statement = statements.get(choix);

        try {
            System.out.print("Nom du Power Mangeur : ");
            try {
                nom_pm = scan.next();
            } catch (Exception e) {
                System.out.println("Problème d'input.");
                return;
            }
            statement.setString(1, nom_pm);

            System.out.print("Nom du Power-Up : ");
            try {
                nom_pu = scan.next();
            } catch (Exception e) {
                System.out.println("Problème d'input.");
                return;
            }
            statement.setString(2, nom_pu);

            System.out.print("Facteur de multiplication du Power-Up : ");
            try {
                facteur_pu = scan.nextInt();
            } catch (Exception e) {
                System.out.println("Problème d'input.");
                return;
            }
            statement.setInt(3, facteur_pu);

        } catch (SQLException e) {
            System.out.println("Erreur avec la base de données.");
            System.exit(1);
        }

        System.out.println("Création du Power-Up en cours...");
        try {
            statement.execute();
            System.out.println("Création réussie !");
        } catch (SQLException e) {
            System.out.println("Problème à la création !");
            System.out.println(e.getMessage());
        }
    }

    private static void classement_pm () {

        String nom_pm;
        int nb_victoires;

        System.out.println("\nClassement des meilleurs Power Mangeurs");
        System.out.println("---------------------------------------\n");

        try {
            ResultSet result = statements.get(choix).executeQuery();
            System.out.println(" ----------------------------- ");
            System.out.println("|  Power Mangeur  | Victoires |");
            System.out.println(" ----------------------------- ");
            while (result.next()) {
                nom_pm = result.getString(1);
                nb_victoires = result.getInt(2);

                System.out.print("| "+nom_pm);
                for (int i = nom_pm.length(); i < 15; i++)
                    System.out.print(" ");
                System.out.println(" |     "+nb_victoires+"     |");
            }
            System.out.println(" ----------------------------- ");
        } catch (SQLException e) {
            System.out.println("Erreur avec la base de données.");
        }

    }

    private static void liste_deces () {

        String nom_pm;
        Date deces;

        System.out.println("\nListe des décès sur l'année");
        System.out.println("---------------------------\n");

        try {
            ResultSet result = statements.get(choix).executeQuery();
            System.out.println(" ------------------------------ ");
            System.out.println("|  Power Mangeur  | Date décès |");
            System.out.println(" ------------------------------ ");
            while (result.next()) {
                nom_pm = result.getString(1);
                deces = result.getDate(2);

                System.out.print("| "+nom_pm);
                for (int i = nom_pm.length(); i < 15; i++)
                    System.out.print(" ");
                System.out.println(" | "+deces+" |");
            }
            System.out.println(" ------------------------------ ");
        } catch (SQLException e) {
            System.out.println("Erreur avec la base de données.");
        }

    }

    private static void historique_combats () {

        String nom_pm, nom_archetype, date_debut, date_fin, victoire;
        Date debut, fin;
        PreparedStatement statement = statements.get(choix);

        System.out.println("\nHistorique des combats");
        System.out.println("----------------------\n");

        try {
            System.out.print("Nom du Power Mangeur : ");
            try {
                nom_pm = scan.next();
            } catch (Exception e) {
                System.out.println("Problème d'input.");
                return;
            }
            statement.setString(1, nom_pm);

            while (true) {
                System.out.print("Début de période : ");
                try {
                    date_debut = scan.next();
                    debut = Date.valueOf(date_debut);
                } catch (IllegalArgumentException e) {
                    System.out.println("La date doit être au format \"YYY-[M]M-[D]D\".");
                    continue;
                } catch (Exception e) {
                    System.out.println("Problème d'input.");
                    return;
                }
                statement.setDate(2, debut);
                break;
            }

            while (true) {
                System.out.print("Fin de période : ");
                try {
                    date_fin = scan.next();
                    fin = Date.valueOf(date_fin);
                } catch (IllegalArgumentException e) {
                    System.out.println("La date doit être au format \"YYY-[M]M-[D]D\".");
                    continue;
                } catch (Exception e) {
                    System.out.println("Problème d'input.");
                    return;
                }
                statement.setDate(3, fin);
                break;
            }

            System.out.println();
        } catch (SQLException e) {
            System.out.println("Erreur avec la base de données.");
            System.exit(1);
        }

        try {
            ResultSet result = statement.executeQuery();
            if (result.next()) {
                System.out.println(" --------------------------------------------------------- ");
                System.out.println("| Monstro-nourriture | Date début |  Date fin  |  Issue   |");
                System.out.println(" --------------------------------------------------------- ");
                do {
                    nom_archetype = result.getString(2);
                    debut = result.getDate(3);
                    fin = result.getDate(4);
                    victoire = result.getBoolean(5) ? "Victoire" : "Défaite ";

                    System.out.print("| "+nom_archetype);
                    for (int i = nom_archetype.length(); i < 18; i++)
                        System.out.print(" ");
                    System.out.println(" | "+debut+" | "+fin+" | "+victoire+" |");
                } while (result.next());
                System.out.println(" --------------------------------------------------------- ");
            }
            else
                System.out.println("Aucun combat trouvé.");
        } catch (SQLException e) {
            System.out.println("Problème avec la requête.");
            System.out.println(e.getMessage());
        }
    }
}

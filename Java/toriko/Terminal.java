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
    private static Connection conn;
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
            conn = DriverManager.getConnection("jdbc:postgresql://"+DB_HOST+"/"+DB_NAME+"?user="+DB_USER+"&password="+DB_PWD);
        } catch (SQLException e) {
            System.out.println("Impossible de joindre le server !");
            System.exit(1);
        }

        try {
            statements = new ArrayList<PreparedStatement>(7);
            statements.add(null);
            statements.add(conn.prepareStatement("SELECT projet.inscrire_pm(?, ?, ?);"));
            statements.add(conn.prepareStatement("SELECT projet.ajouter_archetype(?, ?);"));
            statements.add(conn.prepareStatement("SELECT projet.attribuer_pu(?, ?, ?);"));
        } catch (SQLException e) {
            System.out.println("Problème de requête préparée !");
            e.printStackTrace();
            System.exit(1);
        }

        scan = new Scanner(System.in);

        launch();

    }

    public static void launch () {

        System.out.println("Bienvenue Toriko");
        System.out.println("----------------");

        afficherMenu();

        while (choix != 0) {

            System.out.print("\nQue souhaitez-vous faire ? ");

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
                case 9:
                    afficherMenu();
                    break;
                default:
                    System.out.println("Ceci n'est pas une commande valide.");
                    afficherMenu();
                    break;
            }

        }

        System.out.println("Au revoir !");

    }

    private static void afficherMenu() {
        System.out.println("\nActions possibles :");
        System.out.println("1) Inscription d'un Power Mangeur");
        System.out.println("2) Ajout d'un archétype");
        System.out.println("3) Attribution d'un Power-Up");
        System.out.println("4) Classement des Power Mangeurs");
        System.out.println("5) Liste des Power Mangeurs décédés cette année");
        System.out.println("6) Historique des combats d'un Power Mangeur");
        System.out.println("9) Afficher l'aide");
        System.out.println("0) Quitter l'application");
    }

    private static void inscrire_pm() {

        System.out.println("\nInscription d'un Power Mangeur");
        System.out.println("------------------------------\n");

        String nom, mdp, couleur;
        PreparedStatement statement = statements.get(choix);

        try {
            while (true) {
                System.out.print("Nom : ");
                try {
                    nom = scan.next();
                } catch (Exception e) {
                    System.out.println("Erreur dans le nom.");
                    continue;
                }
                statement.setString(1, nom);
                break;
            }

            while (true) {
                System.out.print("Couleur : ");
                try {
                    couleur = scan.next().trim();
                } catch (Exception e) {
                    System.out.println("Erreur dans la couleur.");
                    continue;
                }
                statement.setString(2, couleur);
                break;
            }

            while (true) {
                System.out.print("Mot de passe : ");
                try {
                    mdp = scan.next();
                } catch (Exception e) {
                    System.out.println("Erreur dans le mot de passe.");
                    continue;
                }
                statement.setString(3, mdp);
                break;
            }
        } catch (SQLException e) {
            System.out.println("La base de données n'est plus accessible !");
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
            while (true) {
                System.out.print("Nom : ");
                try {
                    nom = scan.next();
                } catch (Exception e) {
                    System.out.println("Erreur dans le nom.");
                    continue;
                }
                statement.setString(1, nom);
                break;
            }

            while (true) {
                System.out.print("Facteur : ");
                try {
                    facteur = scan.nextInt();
                } catch (Exception e) {
                    System.out.println("Erreur dans le facteur.");
                    continue;
                }
                statement.setInt(2, facteur);
                break;
            }

        } catch (SQLException e) {
            System.out.println("La base de données n'est plus accessible !");
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

        System.out.println("\nAttribution d'un Power-Up à un Power Mangeur");
        System.out.println("--------------------------------------------\n");

        String nom_pu, nom_pm;
        int facteur_pu;
        PreparedStatement statement = statements.get(choix);

        try {
            while (true) {
                System.out.print("Nom du Power Mangeur : ");
                try {
                    nom_pm = scan.next();
                } catch (Exception e) {
                    System.out.println("Erreur dans le nom du Power Mangeur.");
                    continue;
                }
                statement.setString(1, nom_pm);
                break;
            }

            while (true) {
                System.out.print("Nom du Power-Up : ");
                try {
                    nom_pu = scan.next();
                } catch (Exception e) {
                    System.out.println("Erreur dans le nom du Power-Up.");
                    continue;
                }
                statement.setString(2, nom_pu);
                break;
            }

            while (true) {
                System.out.print("Facteur de multiplication du Power-Up : ");
                try {
                    facteur_pu = scan.nextInt();
                } catch (Exception e) {
                    System.out.println("Erreur dans le facteur.");
                    continue;
                }
                statement.setInt(3, facteur_pu);
                break;
            }
        } catch (SQLException e) {
            System.out.println("La base de données n'est plus accessible !");
            System.exit(1);
        }

        System.out.println("Attribution du Power-Up en cours...");
        try {
            statement.execute();
            System.out.println("Attribution réussie !");
        } catch (SQLException e) {
            System.out.println("Problème à l'attribution !");
            System.out.println(e.getMessage());
        }
    }

    private static void classement_pm () {

        System.out.println("Classement des meilleurs Power Mangeurs");

    }

    private static void liste_deces () {

        System.out.println("Liste des décès sur l'année");

    }

    private static void historique_combats () {

        String nom_pm, date_debut, date_fin;

        System.out.println("Historique des combats");

        System.out.print("Nom du Power Mangeur : ");
        try {
            nom_pm = scan.next();
        } catch (Exception e) {
        }

        System.out.print("Date de début de période : ");
        try {
            date_debut = scan.next();
        } catch (Exception e) {
        }

        System.out.print("Date de fin de période : ");
        try {
            date_fin = scan.next();
        } catch (Exception e) {
        }

        System.out.println("Historique en cours de création...");
    }
}

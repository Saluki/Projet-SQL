import java.sql.*;
import java.util.ArrayList;
import java.util.InputMismatchException;
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
            statements.add(db.prepareStatement("SELECT * FROM projet.classer_pm();"));
            statements.add(db.prepareStatement("SELECT * FROM projet.liste_decedes"));
            statements.add(db.prepareStatement("SELECT nom_archetype AS \"archetype\", date_debut AS \"date\", est_gagne AS \"issue\" FROM projet.historique_combats WHERE nom_pm = ? AND date_debut BETWEEN ? AND ?"));
            statements.add(db.prepareStatement("SELECT nom_pm AS \"power_mangeur\", DATE_TRUNC('DAY', date_debut) AS \"date\", COUNT(*) AS \"nb_combats\" FROM projet.historique_combats WHERE nom_archetype = ? AND date_debut BETWEEN ? AND ? GROUP BY \"power_mangeur\", \"date\"")); // nb_combats: nombre de combats par Power Mangeur par jour
        } catch (SQLException e) {
            System.out.println("Probleme de requete preparee !");
            e.printStackTrace();
            System.exit(1);
        }

        scan = new Scanner(System.in);
        scan.useDelimiter(System.getProperty("line.separator"));

        launch();

        try {
            scan.close();
            db.close();
//            System.out.println("Fermeture de la connexion a la BDD reussie.");
        } catch (SQLException e) {
            System.out.println("Fermeture de la connexion a la BDD echouee.");
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
                scan.nextLine();
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
                    historique_pm();
                    break;
                case 7:
                    historique_archetype();
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
        System.out.println("| 2 | Ajout d'un archetype                          |");
        System.out.println("| 3 | Attribution d'un Power-Up                     |");
        System.out.println("| 4 | Classement des Power Mangeurs                 |");
        System.out.println("| 5 | Liste des Power Mangeurs decedes cette annee  |");
        System.out.println("| 6 | Historique des combats d'un Power Mangeur     |");
        System.out.println("| 7 | Historique des combats d'un archetype         |");
        System.out.println(" ---------------------------------------------------");
        System.out.println("| 0 | Quitter l'application                         |");
        System.out.println(" ---------------------------------------------------");
    }

    private static void inscrire_pm() {

        System.out.println("\nInscription d'un Power Mangeur");
        System.out.println("------------------------------\n");

        String nom = null, mdp, couleur;
        PreparedStatement statement = statements.get(choix);

        try {
            // NOM

            System.out.print("Nom : ");
            try {
                nom = scan.next();
            } catch (Exception e) {
                System.out.println("Probleme d'input.");
                return;
            }
            statement.setString(1, nom);

            // MOT DE PASSE

            System.out.print("Mot de passe : ");
            try {
                mdp = scan.next();
            } catch (Exception e) {
                System.out.println("Probleme d'input.");
                return;
            }
            mdp = CryptService.hash(mdp);
            statement.setString(2, mdp);

            // COULEUR

            System.out.print("Couleur : ");
            try {
                couleur = scan.next();
            } catch (Exception e) {
                System.out.println("Probleme d'input.");
                return;
            }
            statement.setString(3, couleur);

            System.out.println();
        } catch (SQLException e) {
            System.out.println("Erreur avec la base de donnees.");
            System.exit(1);
        }

        System.out.println("Inscription du PM en cours...");
        try {
            statement.execute();
            System.out.println("Inscription reussie !");
        } catch (SQLException e) {
            System.out.println("Probleme a l'inscription !");
            System.out.println(e.getMessage());
        }

    }

    private static void ajouter_monstre () {

        System.out.println("\nAjout d'un archetype de monstro-nourriture");
        System.out.println("------------------------------------------\n");

        String nom;
        int puissance;
        PreparedStatement statement = statements.get(choix);

        try {
            System.out.print("Nom : ");
            try {
                nom = scan.next();
            } catch (Exception e) {
                System.out.println("Probleme d'input.");
                return;
            }
            statement.setString(1, nom);

            System.out.print("Facteur : ");
            try {
                puissance = scan.nextInt();
            } catch (InputMismatchException e) {
                scan.nextLine();
                System.out.println("Problème d'input.");
                return;
            } catch (Exception e) {
                System.out.println("Probleme d'input.");
                return;
            }
            statement.setInt(2, puissance);

            System.out.println();
        } catch (SQLException e) {
            System.out.println("Erreur avec la base de donnees.");
            System.exit(1);
        }

        System.out.println("Ajout de l'archetype en cours...");
        try {
            statement.execute();
            System.out.println("Ajout reussi !");
        } catch (SQLException e) {
            System.out.println("Probleme a l'ajout !");
            System.out.println(e.getMessage());
        }
    }

    private static void attribuer_pu () {

        System.out.println("\nCreation d'un Power-Up");
        System.out.println("----------------------\n");

        String nom_pu, nom_pm;
        int facteur_pu;
        PreparedStatement statement = statements.get(choix);

        try {

            // Liste les PM vivants et stop s'il n'en existe aucun
            ArrayList<String> liste = lister_pm(true);
            if (liste.isEmpty()) {
                System.out.println("Impossible donc d'attribuer de Power-Up.");
                return;
            }

            while (true) {
                System.out.print("Nom du Power Mangeur : ");
                try {
                    nom_pm = scan.next();
                } catch (Exception e) {
                    System.out.println("Probleme d'input.");
                    return;
                }
                if (! liste.contains(nom_pm)) {
                    System.out.println("Ce Power Mangeur n'existe pas.");
                    continue;
                }
                statement.setString(1, nom_pm);
                break;
            }

            System.out.print("Nom du Power-Up : ");
            try {
                nom_pu = scan.next();
            } catch (Exception e) {
                System.out.println("Probleme d'input.");
                return;
            }
            statement.setString(2, nom_pu);

            System.out.print("Facteur de multiplication du Power-Up : ");
            try {
                facteur_pu = scan.nextInt();
            } catch (InputMismatchException e) {
                scan.nextLine();
                System.out.println("Problème d'input.");
                return;
            } catch (Exception e) {
                System.out.println("Probleme d'input.");
                return;
            }
            statement.setInt(3, facteur_pu);

            System.out.println();
        } catch (SQLException e) {
            System.out.println("Erreur avec la base de donnees.");
            System.exit(1);
        }

        System.out.println("Creation du Power-Up en cours...");
        try {
            statement.execute();
            System.out.println("Creation reussie !");
        } catch (SQLException e) {
            System.out.println("Probleme a la creation :");
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
            if (result.next()) {
                System.out.println(" ----------------------------- ");
                System.out.println("|  Power Mangeur  | Victoires |");
                System.out.println(" ----------------------------- ");
                do {
                    nom_pm = result.getString(1);
                    nb_victoires = result.getInt(2);

                    System.out.print("| "+nom_pm);
                    for (int i = nom_pm.length(); i < 15; i++)
                        System.out.print(" ");
                    System.out.println(" |     "+nb_victoires+"     |");
                } while (result.next());
                System.out.println(" ----------------------------- ");
            } else
                System.out.println("Il n'y a aucun Power Mangeur enregistre !");
        } catch (SQLException e) {
            System.out.println("Erreur avec la base de donnees.");
            System.out.println(e.getMessage());
        }

    }

    private static void liste_deces () {

        String nom_pm;
        Date deces;

        System.out.println("\nListe des deces sur l'annee");
        System.out.println("---------------------------\n");

        try {
            ResultSet result = statements.get(choix).executeQuery();
            if (result.next()) {
                System.out.println(" ------------------------------ ");
                System.out.println("|  Power Mangeur  | Date deces |");
                System.out.println(" ------------------------------ ");
                do {
                    nom_pm = result.getString(1);
                    deces = result.getDate(2);

                    System.out.print("| "+nom_pm);
                    for (int i = nom_pm.length(); i < 15; i++)
                        System.out.print(" ");
                    System.out.println(" | "+deces+" |");
                } while (result.next());
                System.out.println(" ------------------------------ ");
            } else
                System.out.println("Bonne nouvelle ! Aucun Power Mangeur n'est mort cette annee !");
        } catch (SQLException e) {
            System.out.println("Erreur avec la base de donnees.");
        }

    }

    private static void historique_pm () {

        String nom_pm, nom_archetype, date_debut, date_fin, issue;
        Date debut, fin;
        PreparedStatement statement = statements.get(choix);

        System.out.println("\nHistorique des combats d'un Power Mangeur");
        System.out.println("-----------------------------------------\n");

        try {

            // Liste tous les PM et stop s'il n'en existe aucun
            ArrayList<String> liste = lister_pm(false);
            if (liste.isEmpty())
                return;

            while (true) {
                System.out.print("Nom du Power Mangeur : ");
                try {
                    nom_pm = scan.next();
                } catch (Exception e) {
                    System.out.println("Probleme d'input.");
                    return;
                }
                if (! liste.contains(nom_pm)) {
                    System.out.println("Ce Power Mangeur n'existe pas.");
                    continue;
                }
                statement.setString(1, nom_pm);
                break;
            }

            while (true) {
                System.out.print("Debut de periode : ");
                try {
                    date_debut = scan.next();
                    debut = Date.valueOf(date_debut);
                } catch (IllegalArgumentException e) {
                    System.out.println("La date doit etre au format \"YYY-[M]M-[D]D\".");
                    continue;
                } catch (Exception e) {
                    System.out.println("Probleme d'input.");
                    return;
                }
                statement.setDate(2, debut);
                break;
            }

            while (true) {
                System.out.print("Fin de periode : ");
                try {
                    date_fin = scan.next();
                    fin = Date.valueOf(date_fin);
                } catch (IllegalArgumentException e) {
                    System.out.println("La date doit etre au format \"YYY-[M]M-[D]D\".");
                    continue;
                } catch (Exception e) {
                    System.out.println("Probleme d'input.");
                    return;
                }
                statement.setDate(3, fin);
                break;
            }

            System.out.println();

            if (debut.after(fin)) {
                System.out.println("Periode invalide !");
                return;
            }

        } catch (SQLException e) {
            System.out.println("Erreur avec la base de donnees.");
            System.exit(1);
        }

        try {
            ResultSet result = statement.executeQuery();
            if (result.next()) {
                System.out.println(" -------------------------------------------- ");
                System.out.println("| Monstro-nourriture |    Date    |  Issue   |");
                System.out.println(" -------------------------------------------- ");
                do {
                    nom_archetype = result.getString("archetype");

                    debut = result.getDate("date");
                    date_debut = debut.toString();

                    if (result.getObject("issue") == null)
                        issue = "En cours";
                    else
                        issue = result.getBoolean("issue") ? "Victoire" : "Defaite ";

                    System.out.print("| "+nom_archetype);
                    for (int i = nom_archetype.length(); i < 18; i++)
                        System.out.print(" ");
                    System.out.println(" | "+date_debut+" | "+issue+" |");
                } while (result.next());
                System.out.println(" -------------------------------------------- ");
            }
            else
                System.out.println("Aucun combat n'a ete trouve.");
        } catch (SQLException e) {
            System.out.println("Probleme avec la requete.");
            System.out.println(e.getMessage());
        }
    }

    private static void historique_archetype () {

        String nom_pm, nom_archetype, date, date_debut, date_fin;
        Date debut, fin;
        int nb_combats;
        PreparedStatement statement = statements.get(choix);

        System.out.println("\nHistorique des combats d'un archetype");
        System.out.println("-------------------------------------\n");

        try {

            // Liste tous les archétypes et stop s'il n'en existe aucun
            ArrayList<String> liste = lister_arch();
            if (liste.isEmpty())
                return;

            System.out.print("Nom de l'archetype : ");
            try {
                nom_archetype = scan.next();
            } catch (Exception e) {
                System.out.println("Probleme d'input.");
                return;
            }
            statement.setString(1, nom_archetype);

            while (true) {
                System.out.print("Debut de periode : ");
                try {
                    date_debut = scan.next();
                    debut = Date.valueOf(date_debut);
                } catch (IllegalArgumentException e) {
                    System.out.println("La date doit etre au format \"YYY-[M]M-[D]D\".");
                    continue;
                } catch (Exception e) {
                    System.out.println("Probleme d'input.");
                    return;
                }
                statement.setDate(2, debut);
                break;
            }

            while (true) {
                System.out.print("Fin de periode : ");
                try {
                    date_fin = scan.next();
                    fin = Date.valueOf(date_fin);
                } catch (IllegalArgumentException e) {
                    System.out.println("La date doit etre au format \"YYY-[M]M-[D]D\".");
                    continue;
                } catch (Exception e) {
                    System.out.println("Probleme d'input.");
                    return;
                }
                statement.setDate(3, fin);
                break;
            }

            System.out.println();
        } catch (SQLException e) {
            System.out.println("Erreur avec la base de donnees.");
            System.exit(1);
        }

        try {
            ResultSet result = statement.executeQuery();
            if (result.next()) {
                System.out.println(" ---------------------------------- ");
                System.out.println("|    Power Mangeur    |    Date    |");
                System.out.println(" ---------------------------------- ");
                do {
                    nom_pm = result.getString("power_mangeur");
                    date = result.getDate("date").toString();
                    nb_combats = result.getInt("nb_combats");
                    if (nb_combats > 1)
                        nom_pm += " ("+nb_combats+"x)";

                    System.out.print("| "+nom_pm);
                    for (int i = nom_pm.length(); i < 19; i++)
                        System.out.print(" ");
                    System.out.println(" | "+date+" |");
                } while (result.next());
                System.out.println(" ---------------------------------- ");
            }
            else
                System.out.println("Aucun combat n'a ete trouve.");
        } catch (SQLException e) {
            System.out.println("Probleme avec la requete.");
            System.out.println(e.getMessage());
        }
    }

    private static ArrayList<String> lister_pm (boolean vivant) throws SQLException {
        String statut, condition = vivant ? " WHERE vie > 0" : "";
        ResultSet liste = db.prepareStatement("SELECT * FROM projet.power_mangeurs"+condition+" ORDER BY date_inscription DESC").executeQuery();
        ArrayList<String> table = new ArrayList<String>();
        if (liste.next()) {
            System.out.println("Power Mangeurs :");
            do {
                statut = (liste.getInt("vie") > 0) ? "+" : "-";
                System.out.println("  "+statut+" "+liste.getString("nom"));
                table.add(liste.getString("nom"));
            } while (liste.next());
            System.out.println();
        } else {
            System.out.println("Aucun Power Mangeur rencense !");
        }
        return table;
    }

    /**
     * Sélectionne en BDD tous les archétypes et les liste par ordre alphabétique
     * @return ArrayList
     * @throws SQLException
     */
    private static ArrayList<String> lister_arch () throws SQLException {
        ResultSet liste = db.prepareStatement("SELECT * FROM projet.archetypes ORDER BY nom").executeQuery();
        ArrayList<String> table = new ArrayList<String>();
        if (liste.next()) {
            System.out.println("Archetypes :");
            do {
                System.out.println("  * "+liste.getString("nom"));
                table.add(liste.getString("nom"));
            } while (liste.next());
            System.out.println();
        } else {
            System.out.println("Aucun archetype rencense !");
        }
        return table;
    }
}

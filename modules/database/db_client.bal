import ballerinax/java.jdbc;

public class DbClient {
    private final jdbc:Client dbClient;

    public function init(string host, string user, string password) returns error? {
        self.dbClient = check new (
            "jdbc:h2:mem:petclinic;DB_CLOSE_DELAY=-1",
            user,
            password
        );
        check self.initDatabase();
    }

    private function initDatabase() returns error? {
        _ = check self.dbClient->execute(`
            CREATE TABLE IF NOT EXISTS owner (
                id INTEGER AUTO_INCREMENT PRIMARY KEY,
                first_name VARCHAR(30) NOT NULL,
                last_name VARCHAR(30) NOT NULL,
                address VARCHAR(255) NOT NULL,
                city VARCHAR(80) NOT NULL,
                telephone VARCHAR(20) NOT NULL
            )
        `);

        _ = check self.dbClient->execute(`
            CREATE TABLE IF NOT EXISTS pet (
                id INTEGER AUTO_INCREMENT PRIMARY KEY,
                name VARCHAR(30) NOT NULL,
                species VARCHAR(30) NOT NULL,
                owner_id INTEGER NOT NULL,
                birth_date DATE NOT NULL,
                FOREIGN KEY (owner_id) REFERENCES owner(id) ON DELETE CASCADE
            )
        `);

        _ = check self.dbClient->execute(`
            CREATE TABLE IF NOT EXISTS vet (
                id INTEGER AUTO_INCREMENT PRIMARY KEY,
                first_name VARCHAR(30) NOT NULL,
                last_name VARCHAR(30) NOT NULL,
                specialty VARCHAR(80) NOT NULL
            )
        `);

        _ = check self.dbClient->execute(`
            CREATE TABLE IF NOT EXISTS visit (
                id INTEGER AUTO_INCREMENT PRIMARY KEY,
                pet_id INTEGER NOT NULL,
                vet_id INTEGER NOT NULL,
                visit_date DATE NOT NULL,
                description VARCHAR(255) NOT NULL,
                FOREIGN KEY (pet_id) REFERENCES pet(id) ON DELETE CASCADE,
                FOREIGN KEY (vet_id) REFERENCES vet(id) ON DELETE CASCADE
            )
        `);
    }

    public function getClient() returns jdbc:Client {
        return self.dbClient;
    }
}

import ballerinax/java.jdbc;

function initDatabase(jdbc:Client dbClient) returns error? {
    // Specialties table
    _ = check dbClient->execute(`
        CREATE TABLE IF NOT EXISTS specialty (
            id INTEGER AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(80) NOT NULL UNIQUE
        )
    `);

    // Pet types table
    _ = check dbClient->execute(`
        CREATE TABLE IF NOT EXISTS pet_type (
            id INTEGER AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(30) NOT NULL UNIQUE
        )
    `);

    // Owner table
    _ = check dbClient->execute(`
        CREATE TABLE IF NOT EXISTS owner (
            id INTEGER AUTO_INCREMENT PRIMARY KEY,
            first_name VARCHAR(30) NOT NULL,
            last_name VARCHAR(30) NOT NULL,
            address VARCHAR(255) NOT NULL,
            city VARCHAR(80) NOT NULL,
            telephone VARCHAR(20) NOT NULL,
            CONSTRAINT uk_owner_phone UNIQUE (telephone)
        )
    `);

    // Vet table
    _ = check dbClient->execute(`
        CREATE TABLE IF NOT EXISTS vet (
            id INTEGER AUTO_INCREMENT PRIMARY KEY,
            first_name VARCHAR(30) NOT NULL,
            last_name VARCHAR(30) NOT NULL
        )
    `);

    // Vet specialties junction table
    _ = check dbClient->execute(`
        CREATE TABLE IF NOT EXISTS vet_specialty (
            vet_id INTEGER NOT NULL,
            specialty_id INTEGER NOT NULL,
            PRIMARY KEY (vet_id, specialty_id),
            FOREIGN KEY (vet_id) REFERENCES vet(id) ON DELETE CASCADE,
            FOREIGN KEY (specialty_id) REFERENCES specialty(id)
        )
    `);

    // Pet table with type reference
    _ = check dbClient->execute(`
        CREATE TABLE IF NOT EXISTS pet (
            id INTEGER AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(30) NOT NULL,
            birth_date DATE NOT NULL,
            type_id INTEGER NOT NULL,
            owner_id INTEGER NOT NULL,
            FOREIGN KEY (type_id) REFERENCES pet_type(id),
            FOREIGN KEY (owner_id) REFERENCES owner(id) ON DELETE CASCADE
        )
    `);

    // Visit table
    _ = check dbClient->execute(`
        CREATE TABLE IF NOT EXISTS visit (
            id INTEGER AUTO_INCREMENT PRIMARY KEY,
            pet_id INTEGER NOT NULL,
            vet_id INTEGER NOT NULL,
            visit_date DATE NOT NULL,
            description VARCHAR(255) NOT NULL,
            FOREIGN KEY (pet_id) REFERENCES pet(id) ON DELETE CASCADE,
            FOREIGN KEY (vet_id) REFERENCES vet(id)
        )
    `);

    // Appointments table
    _ = check dbClient->execute(`
        CREATE TABLE IF NOT EXISTS appointment (
            id INTEGER AUTO_INCREMENT PRIMARY KEY,
            pet_id INTEGER NOT NULL,
            vet_id INTEGER NOT NULL,
            appointment_datetime TIMESTAMP NOT NULL,
            status VARCHAR(20) NOT NULL DEFAULT 'SCHEDULED',
            notes VARCHAR(255),
            FOREIGN KEY (pet_id) REFERENCES pet(id) ON DELETE CASCADE,
            FOREIGN KEY (vet_id) REFERENCES vet(id),
            CONSTRAINT uk_appointment UNIQUE (vet_id, appointment_datetime)
        )
    `);

    // Insert default specialties
    _ = check dbClient->execute(`
        INSERT INTO specialty (name) VALUES 
        ('radiology'),
        ('surgery'),
        ('dentistry')
        ON DUPLICATE KEY UPDATE name=name
    `);

    // Insert default pet types
    _ = check dbClient->execute(`
        INSERT INTO pet_type (name) VALUES 
        ('cat'),
        ('dog'),
        ('bird'),
        ('hamster'),
        ('snake')
        ON DUPLICATE KEY UPDATE name=name
    `);
}

import petclinic.types;

import ballerina/sql;
import ballerinax/java.jdbc;

public class PetRepository {
    private final jdbc:Client dbClient;

    public function init(jdbc:Client dbClient) {
        self.dbClient = dbClient;
    }

    public function create(types:Pet pet) returns types:Pet|error {
        sql:ExecutionResult result = check self.dbClient->execute(`
            INSERT INTO pet(name, species, owner_id, birth_date)
            VALUES (${pet.name}, ${pet.species}, ${pet.ownerId}, ${pet.birthDate})
        `);
        pet.id = <int>result.lastInsertId;
        return pet;
    }

    public function getById(int id) returns types:Pet|error {
        types:Pet|error result = self.dbClient->queryRow(`
            SELECT 
                id,
                name,
                species,
                owner_id as ownerId,
                birth_date as birthDate
            FROM pet WHERE id = ${id}
        `);
        return result;
    }

    public function getByOwnerId(int ownerId) returns types:Pet[]|error {
        stream<types:Pet, sql:Error?> petStream = self.dbClient->query(`
            SELECT 
                id,
                name,
                species,
                owner_id as ownerId,
                birth_date as birthDate
            FROM pet
            WHERE owner_id = ${ownerId}
        `);
        types:Pet[] pets = check from types:Pet pet in petStream
            select pet;
        check petStream.close();
        return pets;
    }
}

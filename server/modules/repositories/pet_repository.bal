import petclinic.types;

import ballerina/sql;
import ballerinax/java.jdbc;

public class PetRepository {
    private final jdbc:Client dbClient;
    private final OwnerRepository ownerRepo;

    public function init(jdbc:Client dbClient) {
        self.dbClient = dbClient;
        self.ownerRepo = new (self.dbClient);
    }

    public function create(types:Pet pet) returns types:Pet|error {
        // Validate required fields
        if pet.name.trim().length() == 0 {
            return error types:RequestValidationError("Invalid pet name",
            entity = "pet",
            fieldname = "name",
            message = "Pet name cannot be empty"
            );
        }
        if pet.species.trim().length() == 0 {
            return error types:RequestValidationError("Invalid species",
            entity = "pet",
            fieldname = "species",
            message = "Species cannot be empty"
            );
        }

        // Check owner exists
        types:Owner|error owner = self.ownerRepo.getById(pet.ownerId);
        if owner is error {
            return error types:ResourceNotFoundError("Owner not found",
            entity = "owner",
            id = pet.ownerId,
            message = "Owner not found"
            );
        }

        // Insert pet with transaction
        transaction {
            sql:ExecutionResult|sql:Error result = check self.dbClient->execute(`
            INSERT INTO pet(name, species, owner_id, birth_date)
            VALUES (${pet.name}, ${pet.species}, ${pet.ownerId}, ${pet.birthDate})
        `);

            if result is sql:Error {
                rollback;
                return error types:DatabaseError("Database operation failed",
                operation = "create",
                entity = "pet",
                message = "Failed to create pet record",
                cause = error(result.message())
                );
            } else {
                check commit;
                pet.id = <int>result.lastInsertId;
            }
        } on fail error e {
            return error types:TransactionError("Transaction failed",
            operation = "create",
            entity = "pet",
            message = "Failed to complete pet creation transaction",
            cause = e
            );
        }

        return pet;
    }

    public function update(int id, types:Pet pet) returns types:Pet|error {

        //check if pet exists
        types:Pet|error existingPet = self.getById(id);
        if existingPet is error {
            return error types:ResourceNotFoundError("Pet not found",
            entity = "pet",
            id = id,
            message = "Pet not found with the given ID"
            );
        }

        // Validate required fields
        if pet.name.trim().length() == 0 {
            return error types:RequestValidationError("Invalid pet name",
            entity = "pet",
            fieldname = "name",
            message = "Pet name cannot be empty"
            );
        }
        if pet.species.trim().length() == 0 {
            return error types:RequestValidationError("Invalid species",
            entity = "pet",
            fieldname = "species",
            message = "Species cannot be empty"
            );
        }

        // Check owner exists
        types:Owner|error owner = self.ownerRepo.getById(pet.ownerId);
        if owner is error {
            return error types:ResourceNotFoundError("Owner not found",
            entity = "owner",
            id = pet.ownerId,
            message = "Owner not found"
            );
        }

        // Update pet with transaction
        transaction {
            sql:ExecutionResult|sql:Error result = check self.dbClient->execute(`
            UPDATE pet 
            SET name = ${pet.name},
                species = ${pet.species},
                owner_id = ${pet.ownerId},
                birth_date = ${pet.birthDate}
            WHERE id = ${id}
        `);

            if result is sql:Error {
                rollback;
                return error types:DatabaseError("Database operation failed",
                operation = "update",
                entity = "pet",
                message = "Failed to update pet record",
                cause = error(result.message())
                );
            } else {

                if result.affectedRowCount == 0 {
                    rollback;
                    return error types:ResourceNotFoundError("Pet not found",
                    entity = "pet",
                    id = id,
                    message = "Pet not found with the given ID"
                    );
                } else {
                    check commit;
                }
            }

            pet.id = id;
        } on fail error e {
            return error types:TransactionError("Transaction failed",
            operation = "update",
            entity = "pet",
            message = "Failed to complete pet update transaction",
            cause = e
            );
        }

        return pet;
    }

    public function delete(int id) returns error? {
        transaction {
            // First check if pet exists
            types:Pet|error pet = self.getById(id);
            if pet is error {
                rollback;
                return error types:ResourceNotFoundError("Pet not found",
                entity = "pet",
                id = id,
                message = "Pet not found with the given ID"
                );
            } else {

                sql:ExecutionResult|sql:Error result = check self.dbClient->execute(`
            DELETE FROM pet WHERE id = ${id}
        `);

                if result is sql:Error {
                    rollback;
                    return error types:DatabaseError("Database operation failed",
                    operation = "delete",
                    entity = "pet",
                    message = "Failed to delete pet record",
                    cause = error(result.message())
                    );
                } else {
                    check commit;
                }
            }
        } on fail error e {
            return error types:TransactionError("Transaction failed",
            operation = "delete",
            entity = "pet",
            message = "Failed to complete pet deletion transaction",
            cause = e
            );
        }
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

        if result is sql:NoRowsError {
            return error types:ResourceNotFoundError("Pet not found",
            entity = "pet",
            id = id,
            message = "Pet not found with the given ID"
            );
        }

        if result is error {
            return error types:DatabaseError("Database operation failed",
            operation = "getById",
            entity = "pet",
            message = "Failed to retrieve pet record",
            cause = error(result.message())
            );
        }

        return result;
    }

    public function getAll() returns types:Pet[]|error {
        stream<types:Pet, sql:Error?> petStream = self.dbClient->query(`
        SELECT 
            id,
            name,
            species,
            owner_id as ownerId,
            birth_date as birthDate
        FROM pet
    `);

        types:Pet[]|error pets = trap from types:Pet pet in petStream
            select pet;

        check petStream.close();

        if pets is error {
            return error types:DatabaseError("Database operation failed",
            operation = "getAll",
            entity = "pet",
            message = "Failed to retrieve pet records",
            cause = pets
            );
        }

        return pets;
    }

    public function getByOwnerId(int ownerId) returns types:Pet[]|error {
        // First check if owner exists
        types:Owner|error owner = self.ownerRepo.getById(ownerId);
        if owner is error {
            return error types:ResourceNotFoundError("Owner not found",
            entity = "owner",
            id = ownerId,
            message = "Owner not found with the given ID"
            );
        }

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

        types:Pet[]|error pets = trap from types:Pet pet in petStream
            select pet;

        check petStream.close();

        if pets is error {
            return error types:DatabaseError("Database operation failed",
            operation = "getByOwnerId",
            entity = "pet",
            message = "Failed to retrieve pet records by owner",
            cause = pets
            );
        }

        return pets;
    }
}

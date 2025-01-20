import petclinic.types;

import ballerina/sql;
import ballerinax/java.jdbc;

public class OwnerRepository {
    private final jdbc:Client dbClient;

    public function init(jdbc:Client dbClient) {
        self.dbClient = dbClient;
    }

    public function create(types:Owner owner) returns types:Owner|error {
        sql:ExecutionResult result = check self.dbClient->execute(`
            INSERT INTO owner(first_name, last_name, address, city, telephone)
            VALUES (${owner.firstName}, ${owner.lastName}, ${owner.address}, 
                    ${owner.city}, ${owner.telephone})
        `);
        owner.id = <int>result.lastInsertId;
        return owner;
    }

    public function getById(int id) returns types:Owner|error {
        types:Owner|error result = self.dbClient->queryRow(`
            SELECT 
                id,
                first_name as firstName,
                last_name as lastName,
                address,
                city,
                telephone
            FROM owner WHERE id = ${id}
        `);
        return result;
    }

    public function getAll() returns types:Owner[]|error {
        stream<types:Owner, sql:Error?> ownerStream = self.dbClient->query(`
            SELECT 
                id,
                first_name as firstName,
                last_name as lastName,
                address,
                city,
                telephone
            FROM owner
        `);
        types:Owner[] owners = check from types:Owner owner in ownerStream
            select owner;
        check ownerStream.close();
        return owners;
    }

    public function update(int id, types:Owner owner) returns types:Owner|error {
        sql:ExecutionResult result = check self.dbClient->execute(`
            UPDATE owner 
            SET first_name = ${owner.firstName},
                last_name = ${owner.lastName},
                address = ${owner.address},
                city = ${owner.city},
                telephone = ${owner.telephone}
            WHERE id = ${id}
        `);
        if result.affectedRowCount == 0 {
            return error("Owner not found");
        }
        owner.id = id;
        return owner;
    }

    public function delete(int id) returns error? {
        sql:ExecutionResult result = check self.dbClient->execute(`
            DELETE FROM owner WHERE id = ${id}
        `);
        if result.affectedRowCount == 0 {
            return error("Owner not found");
        }
    }
}

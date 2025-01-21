import petclinic.types;

import ballerina/sql;
import ballerinax/java.jdbc;

public class SpecialtyRepository {
    private final jdbc:Client dbClient;

    public function init(jdbc:Client dbClient) {
        self.dbClient = dbClient;
    }

    public function create(types:Specialty specialty) returns types:Specialty|error {
        sql:ExecutionResult result = check self.dbClient->execute(`
            INSERT INTO specialty(name)
            VALUES (${specialty.name})
        `);
        specialty.id = <int>result.lastInsertId;
        return specialty;
    }

    public function getById(int id) returns types:Specialty|error {
        types:Specialty|error result = self.dbClient->queryRow(`
            SELECT id, name
            FROM specialty 
            WHERE id = ${id}
        `);
        return result;
    }

    public function getAll() returns types:Specialty[]|error {
        stream<types:Specialty, sql:Error?> specialtyStream = self.dbClient->query(`
            SELECT id, name FROM specialty ORDER BY name
        `);
        types:Specialty[] specialties = check from types:Specialty specialty in specialtyStream
            select specialty;
        check specialtyStream.close();
        return specialties;
    }

    public function update(int id, types:Specialty specialty) returns types:Specialty|error {
        sql:ExecutionResult result = check self.dbClient->execute(`
            UPDATE specialty 
            SET name = ${specialty.name}
            WHERE id = ${id}
        `);
        if result.affectedRowCount == 0 {
            return error("Specialty not found");
        }
        specialty.id = id;
        return specialty;
    }

    public function delete(int id) returns error? {
        sql:ExecutionResult result = check self.dbClient->execute(`
            DELETE FROM specialty WHERE id = ${id}
        `);
        if result.affectedRowCount == 0 {
            return error("Specialty not found");
        }
    }
}

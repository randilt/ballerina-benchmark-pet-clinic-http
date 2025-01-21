import petclinic.types;

import ballerina/sql;
import ballerinax/java.jdbc;

public class VisitRepository {
    private final jdbc:Client dbClient;

    public function init(jdbc:Client dbClient) {
        self.dbClient = dbClient;
    }

    public function create(types:Visit visit) returns types:Visit|error {
        sql:ExecutionResult result = check self.dbClient->execute(`
            INSERT INTO visit(pet_id, vet_id, visit_date, description)
            VALUES (${visit.petId}, ${visit.vetId}, ${visit.visitDate}, ${visit.description})
        `);
        visit.id = <int>result.lastInsertId;
        return visit;
    }

    public function update(int id, types:Visit visit) returns types:Visit|error {
        sql:ExecutionResult result = check self.dbClient->execute(`
        UPDATE visit 
        SET pet_id = ${visit.petId},
            vet_id = ${visit.vetId},
            visit_date = ${visit.visitDate},
            description = ${visit.description}
        WHERE id = ${id}
    `);
        if result.affectedRowCount == 0 {
            return error("Visit not found");
        }
        visit.id = id;
        return visit;
    }

    public function delete(int id) returns error? {
        sql:ExecutionResult result = check self.dbClient->execute(`
        DELETE FROM visit WHERE id = ${id}
    `);
        if result.affectedRowCount == 0 {
            return error("Visit not found");
        }
    }

    public function getById(int id) returns types:Visit|error {
        types:Visit|error result = self.dbClient->queryRow(`
            SELECT 
                id,
                pet_id as petId,
                vet_id as vetId,
                visit_date as visitDate,
                description
            FROM visit WHERE id = ${id}
        `);
        return result;
    }

    public function getByPetId(int petId) returns types:Visit[]|error {
        stream<types:Visit, sql:Error?> visitStream = self.dbClient->query(`
            SELECT 
                id,
                pet_id as petId,
                vet_id as vetId,
                visit_date as visitDate,
                description
            FROM visit
            WHERE pet_id = ${petId}
        `);
        types:Visit[] visits = check from types:Visit visit in visitStream
            select visit;
        check visitStream.close();
        return visits;
    }
}

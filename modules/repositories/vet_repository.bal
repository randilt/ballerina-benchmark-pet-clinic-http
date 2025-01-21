import petclinic.types;

import ballerina/sql;
import ballerinax/java.jdbc;

public class VetRepository {
    private final jdbc:Client dbClient;

    public function init(jdbc:Client dbClient) {
        self.dbClient = dbClient;
    }

    public function create(types:Vet vet) returns types:Vet|error {
        transaction {
            sql:ExecutionResult result = check self.dbClient->execute(`
                INSERT INTO vet(first_name, last_name)
                VALUES (${vet.firstName}, ${vet.lastName})
            `);

            int vetId = <int>result.lastInsertId;

            foreach var specialty in vet.specialties {
                _ = check self.dbClient->execute(`
                    INSERT INTO vet_specialty(vet_id, specialty_id)
                    VALUES (${vetId}, ${specialty.id})
                `);
            }

            vet.id = vetId;
            check commit;
            return vet;
        } on fail error e {
            return e;
        }
    }

    public function getById(int id) returns types:Vet|error {
        types:Vet vet = check self.dbClient->queryRow(`
            SELECT 
                v.id,
                v.first_name as firstName,
                v.last_name as lastName
            FROM vet v
            WHERE v.id = ${id}
        `);

        vet.specialties = check self.getSpecialties(id);
        return vet;
    }

    private function getSpecialties(int vetId) returns types:Specialty[]|error {
        stream<types:Specialty, sql:Error?> specialtyStream = self.dbClient->query(`
            SELECT 
                s.id,
                s.name
            FROM specialty s
            JOIN vet_specialty vs ON s.id = vs.specialty_id
            WHERE vs.vet_id = ${vetId}
        `);

        types:Specialty[] specialties = check from types:Specialty specialty in specialtyStream
            select specialty;
        check specialtyStream.close();
        return specialties;
    }

    public function getAll() returns types:Vet[]|error {
        stream<record {|int id; string firstName; string lastName;|}, sql:Error?> vetStream =
            self.dbClient->query(`SELECT id, first_name as firstName, last_name as lastName FROM vet`);

        types:Vet[] vets = [];
        check from record {|int id; string firstName; string lastName;|} vetRecord in vetStream
            do {
                types:Vet vet = {
                    id: vetRecord.id,
                    firstName: vetRecord.firstName,
                    lastName: vetRecord.lastName,
                    specialties: check self.getSpecialties(vetRecord.id)
                };
                vets.push(vet);
            };
        check vetStream.close();
        return vets;
    }

    public function update(int id, types:Vet vet) returns types:Vet|error {
        transaction {
            sql:ExecutionResult result = check self.dbClient->execute(`
                UPDATE vet 
                SET first_name = ${vet.firstName},
                    last_name = ${vet.lastName}
                WHERE id = ${id}
            `);

            if result.affectedRowCount == 0 {
                rollback;
                return error("Vet not found");
            } else {

                _ = check self.dbClient->execute(`DELETE FROM vet_specialty WHERE vet_id = ${id}`);

                foreach var specialty in vet.specialties {
                    _ = check self.dbClient->execute(`
                    INSERT INTO vet_specialty(vet_id, specialty_id)
                    VALUES (${id}, ${specialty.id})
                `);
                }

                check commit;
                vet.id = id;
                return vet;
            }
        }
    }

    public function delete(int id) returns error? {
        sql:ExecutionResult result = check self.dbClient->execute(`
            DELETE FROM vet WHERE id = ${id}
        `);
        if result.affectedRowCount == 0 {
            return error("Vet not found");
        }
    }
}

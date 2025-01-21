import petclinic.types;

import ballerina/sql;
import ballerina/time;
import ballerinax/java.jdbc;

public class AppointmentRepository {
    private final jdbc:Client dbClient;

    public function init(jdbc:Client dbClient) {
        self.dbClient = dbClient;
    }

    public function create(types:Appointment appointment) returns types:Appointment|error {
        sql:ExecutionResult result = check self.dbClient->execute(`
            INSERT INTO appointment(pet_id, vet_id, appointment_datetime, status, notes)
            VALUES (${appointment.petId}, ${appointment.vetId}, 
                    ${appointment.dateTime}, ${appointment.status}, ${appointment.notes})
        `);
        appointment.id = <int>result.lastInsertId;
        return appointment;
    }

    public function getById(int id) returns types:Appointment|error {
        types:Appointment|error result = self.dbClient->queryRow(`
            SELECT 
                id,
                pet_id as petId,
                vet_id as vetId,
                appointment_datetime as dateTime,
                status,
                notes
            FROM appointment 
            WHERE id = ${id}
        `);
        return result;
    }

    public function update(int id, types:Appointment appointment) returns types:Appointment|error {
        sql:ExecutionResult result = check self.dbClient->execute(`
        UPDATE appointment 
        SET pet_id = ${appointment.petId},
            vet_id = ${appointment.vetId},
            appointment_datetime = ${appointment.dateTime},
            status = ${appointment.status},
            notes = ${appointment.notes}
        WHERE id = ${id}
    `);
        if result.affectedRowCount == 0 {
            return error("Appointment not found");
        }
        appointment.id = id;
        return appointment;
    }

    public function getUpcomingByVetId(int vetId, time:Civil fromDate) returns types:Appointment[]|error {
        stream<types:Appointment, sql:Error?> appointmentStream = self.dbClient->query(`
            SELECT 
                id,
                pet_id as petId,
                vet_id as vetId,
                appointment_datetime as dateTime,
                status,
                notes
            FROM appointment
            WHERE vet_id = ${vetId}
            AND appointment_datetime >= ${fromDate}
            AND status = 'SCHEDULED'
            ORDER BY appointment_datetime
        `);
        types:Appointment[] appointments = check from types:Appointment appointment in appointmentStream
            select appointment;
        check appointmentStream.close();
        return appointments;
    }

    public function getAll() returns types:Appointment[]|error {
        stream<types:Appointment, sql:Error?> appointmentStream = self.dbClient->query(`
            SELECT 
                id,
                pet_id as petId,
                vet_id as vetId,
                appointment_datetime as dateTime,
                status,
                notes
            FROM appointment
            ORDER BY appointment_datetime DESC
        `);
        types:Appointment[] appointments = check from types:Appointment appointment in appointmentStream
            select appointment;
        check appointmentStream.close();
        return appointments;
    }

    public function getByPetId(int petId) returns types:Appointment[]|error {
        stream<types:Appointment, sql:Error?> appointmentStream = self.dbClient->query(`
            SELECT 
                id,
                pet_id as petId,
                vet_id as vetId,
                appointment_datetime as dateTime,
                status,
                notes
            FROM appointment
            WHERE pet_id = ${petId}
            ORDER BY appointment_datetime DESC
        `);
        types:Appointment[] appointments = check from types:Appointment appointment in appointmentStream
            select appointment;
        check appointmentStream.close();
        return appointments;
    }

    public function updateStatus(int id, string status) returns types:Appointment|error {
        sql:ExecutionResult result = check self.dbClient->execute(`
            UPDATE appointment 
            SET status = ${status}
            WHERE id = ${id}
        `);
        if result.affectedRowCount == 0 {
            return error("Appointment not found");
        }
        return check self.getById(id);
    }

    public function delete(int id) returns error? {
        sql:ExecutionResult result = check self.dbClient->execute(`
            DELETE FROM appointment WHERE id = ${id}
        `);
        if result.affectedRowCount == 0 {
            return error("Appointment not found");
        }
    }

    public function isVetAvailable(int vetId, time:Civil dateTime) returns boolean|error {
        int|error count = self.dbClient->queryRow(`
            SELECT COUNT(*) as count
            FROM appointment
            WHERE vet_id = ${vetId}
            AND appointment_datetime = ${dateTime}
            AND status = 'SCHEDULED'
        `);

        if count is error {
            return error("Error checking vet availability");
        }

        return count == 0;
    }
}

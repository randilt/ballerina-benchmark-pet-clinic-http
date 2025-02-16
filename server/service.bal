import petclinic.database as db;
import petclinic.repositories as repos;
import petclinic.types;

import ballerina/http;
import ballerina/time;

configurable string dbHost = "localhost";
configurable string dbUser = "sa";
configurable string dbPassword = "";
configurable int port = 8080;

@http:ServiceConfig {
    cors: {
        allowOrigins: ["http://localhost:3000"],
        allowCredentials: false,
        allowHeaders: ["CORELATION_ID", "Content-Type", "Authorization"],
        allowMethods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        exposeHeaders: ["X-CUSTOM-HEADER"],
        maxAge: 84900
    }
}
service / on new http:Listener(port) {
    private final db:DbClient dbClient;
    private final repos:OwnerRepository ownerRepo;
    private final repos:PetRepository petRepo;
    private final repos:VisitRepository visitRepo;
    private final repos:VetRepository vetRepo;
    private final repos:SpecialtyRepository specialtyRepo;
    private final repos:AppointmentRepository appointmentRepo;

    function init() returns error? {
        self.dbClient = check new (dbHost, dbUser, dbPassword);
        self.ownerRepo = new (self.dbClient.getClient());
        self.petRepo = new (self.dbClient.getClient());
        self.visitRepo = new (self.dbClient.getClient());
        self.vetRepo = new (self.dbClient.getClient());
        self.specialtyRepo = new (self.dbClient.getClient());
        self.appointmentRepo = new (self.dbClient.getClient());

    }

    // owner endpoints
    resource function post owners(@http:Payload types:Owner payload) returns types:Owner|error {
        return self.ownerRepo.create(payload);
    }

    resource function get owners/[int id]() returns types:Owner|http:NotFound|error {
        types:Owner|error result = self.ownerRepo.getById(id);
        if result is error {
            return http:NOT_FOUND;
        }
        return result;
    }

    resource function get owners() returns types:Owner[]|error {
        return self.ownerRepo.getAll();
    }

    resource function put owners/[int id](@http:Payload types:Owner payload) returns types:Owner|http:NotFound|error {
        types:Owner|error result = self.ownerRepo.update(id, payload);
        if result is error {
            return http:NOT_FOUND;
        }
        return result;
    }

    resource function delete owners/[int id]() returns http:Ok|http:NotFound|error {
        error? result = self.ownerRepo.delete(id);
        if result is error {
            return http:NOT_FOUND;
        }
        return http:OK;
    }

    // pet endpoints
    // Function to add a new pet
    resource function post pets(@http:Payload types:Pet payload) returns http:Response {
        http:Response response = new;

        do {
            types:Pet result = check self.petRepo.create(payload);
            response.statusCode = http:STATUS_CREATED;
            response.setJsonPayload(result);
        } on fail error e {
            types:ErrorResponse errResp = {
                status: self.getStatusCode(e),
                message: e.message(),
                details: <json>e.detail()
            };
            response.statusCode = errResp.status;
            response.setJsonPayload(errResp);
        }

        return response;
    }

    // Function to get all pets
    resource function get pets() returns http:Response {
        http:Response response = new;

        do {
            types:Pet[] result = check self.petRepo.getAll();
            response.setJsonPayload(result);
        } on fail error e {
            types:ErrorResponse errResp = {
                status: self.getStatusCode(e),
                message: e.message(),
                details: <json>e.detail()
            };
            response.statusCode = errResp.status;
            response.setJsonPayload(errResp);
        }

        return response;
    }

    // Function to get a pet by ID
    resource function get pets/[int id]() returns http:Response {
        http:Response response = new;

        do {
            types:Pet result = check self.petRepo.getById(id);
            response.setJsonPayload(result);
        } on fail error e {
            types:ErrorResponse errResp = {
                status: self.getStatusCode(e),
                message: e.message(),
                details: <json>e.detail()
            };
            response.statusCode = errResp.status;
            response.setJsonPayload(errResp);
        }

        return response;
    }

    // Function to get all pets by owner ID
    resource function get owners/[int id]/pets() returns http:Response {
        http:Response response = new;

        do {
            types:Pet[] result = check self.petRepo.getByOwnerId(id);
            response.setJsonPayload(result);
        } on fail error e {
            types:ErrorResponse errResp = {
                status: self.getStatusCode(e),
                message: e.message(),
                details: <json>e.detail()
            };
            response.statusCode = errResp.status;
            response.setJsonPayload(errResp);
        }

        return response;
    }

    // Function to update a pet by ID   
    resource function put pets/[int id](@http:Payload types:Pet payload) returns http:Response {
        http:Response response = new;

        do {
            types:Pet result = check self.petRepo.update(id, payload);
            response.setJsonPayload(result);
        } on fail error e {
            types:ErrorResponse errResp = {
                status: self.getStatusCode(e),
                message: e.message(),
                details: <json>e.detail()
            };
            response.statusCode = errResp.status;
            response.setJsonPayload(errResp);
        }

        return response;
    }

    // Function to delete a pet by ID
    resource function delete pets/[int id]() returns http:Response {
        http:Response response = new;

        do {
            check self.petRepo.delete(id);
            response.statusCode = http:STATUS_NO_CONTENT;
        } on fail error e {
            types:ErrorResponse errResp = {
                status: self.getStatusCode(e),
                message: e.message(),
                details: <json>e.detail()
            };
            response.statusCode = errResp.status;
            response.setJsonPayload(errResp);
        }

        return response;
    }

    // visit endpoints
    resource function post visits(@http:Payload types:Visit payload) returns types:Visit|error {
        return self.visitRepo.create(payload);
    }

    resource function get visits/[int id]() returns types:Visit|http:NotFound|error {
        types:Visit|error result = self.visitRepo.getById(id);
        if result is error {
            return http:NOT_FOUND;
        }
        return result;
    }

    resource function get pets/[int id]/visits() returns types:Visit[]|error {
        return self.visitRepo.getByPetId(id);
    }

    // resource function get vets/[int id]/visits() returns types:Visit[]|error {
    //     return self.visitRepo.getByVetId(id);
    // }

    resource function put visits/[int id](@http:Payload types:Visit payload) returns types:Visit|http:NotFound|error {
        types:Visit|error result = self.visitRepo.update(id, payload);
        if result is error {
            return http:NOT_FOUND;
        }
        return result;
    }

    resource function delete visits/[int id]() returns http:Ok|http:NotFound|error {
        error? result = self.visitRepo.delete(id);
        if result is error {
            return http:NOT_FOUND;
        }
        return http:OK;
    }

    // vet endpoints
    resource function post vets(@http:Payload types:Vet payload) returns types:Vet|error {
        return self.vetRepo.create(payload);
    }

    resource function get vets/[int id]() returns types:Vet|http:NotFound|error {
        types:Vet|error result = self.vetRepo.getById(id);
        if result is error {
            return http:NOT_FOUND;
        }
        return result;
    }

    resource function get vets() returns types:Vet[]|error {
        return self.vetRepo.getAll();
    }

    resource function put vets/[int id](@http:Payload types:Vet payload) returns types:Vet|http:NotFound|error {
        types:Vet|error result = self.vetRepo.update(id, payload);
        if result is error {
            return http:NOT_FOUND;
        }
        return result;
    }

    resource function delete vets/[int id]() returns http:Ok|http:NotFound|error {
        error? result = self.vetRepo.delete(id);
        if result is error {
            return http:NOT_FOUND;
        }
        return http:OK;
    }

    // specialty endpoints
    resource function post specialties(@http:Payload types:Specialty payload) returns types:Specialty|error {
        return self.specialtyRepo.create(payload);
    }

    resource function get specialties/[int id]() returns types:Specialty|http:NotFound|error {
        types:Specialty|error result = self.specialtyRepo.getById(id);
        if result is error {
            return http:NOT_FOUND;
        }
        return result;
    }

    resource function get specialties() returns types:Specialty[]|error {
        return self.specialtyRepo.getAll();
    }

    resource function put specialties/[int id](@http:Payload types:Specialty payload) returns types:Specialty|http:NotFound|error {
        types:Specialty|error result = self.specialtyRepo.update(id, payload);
        if result is error {
            return http:NOT_FOUND;
        }
        return result;
    }

    resource function delete specialties/[int id]() returns http:Ok|http:NotFound|error {
        error? result = self.specialtyRepo.delete(id);
        if result is error {
            return http:NOT_FOUND;
        }
        return http:OK;
    }

    // appointment endpoints
    resource function post appointments(@http:Payload types:Appointment payload) returns types:Appointment|error {
        return self.appointmentRepo.create(payload);
    }

    resource function get appointments/[int id]() returns types:Appointment|http:NotFound|error {
        types:Appointment|error result = self.appointmentRepo.getById(id);
        if result is error {
            return http:NOT_FOUND;
        }
        return result;
    }

    resource function get appointments() returns types:Appointment[]|error {
        return self.appointmentRepo.getAll();
    }

    resource function get vets/[int id]/appointments/upcoming() returns types:Appointment[]|error {
        time:Civil now = time:utcToCivil(time:utcNow());
        return self.appointmentRepo.getUpcomingByVetId(id, now);
    }

    resource function get pets/[int id]/appointments() returns types:Appointment[]|error {
        return self.appointmentRepo.getByPetId(id);
    }

    resource function put appointments/[int id](@http:Payload types:Appointment payload) returns types:Appointment|http:NotFound|error {
        types:Appointment|error result = self.appointmentRepo.update(id, payload);
        if result is error {
            return http:NOT_FOUND;
        }
        return result;
    }

    resource function put appointments/[int id]/status(@http:Payload string status) returns types:Appointment|http:NotFound|error {
        types:Appointment|error result = self.appointmentRepo.updateStatus(id, status);
        if result is error {
            return http:NOT_FOUND;
        }
        return result;
    }

    resource function delete appointments/[int id]() returns http:Ok|http:NotFound|error {
        error? result = self.appointmentRepo.delete(id);
        if result is error {
            return http:NOT_FOUND;
        }
        return http:OK;
    }

    resource function get vets/[int id]/available(time:Civil dateTime) returns boolean|error {
        return self.appointmentRepo.isVetAvailable(id, dateTime);
    }

    private function getStatusCode(error e) returns int {
        if e is types:ResourceNotFoundError {
            return http:STATUS_NOT_FOUND;
        } else if e is types:DatabaseError {
            return http:STATUS_INTERNAL_SERVER_ERROR;
        } else if e is types:ValidationError {
            return http:STATUS_BAD_REQUEST;
        } else if e is types:TransactionError {
            return http:STATUS_INTERNAL_SERVER_ERROR;
        } else if e is types:RequestValidationError {
            return http:STATUS_BAD_REQUEST;
        } else {
            return http:STATUS_INTERNAL_SERVER_ERROR;
        }
    }

}

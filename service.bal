import petclinic.database as db;
import petclinic.repositories as repos;
import petclinic.types;

import ballerina/http;

configurable string dbHost = "localhost";
configurable string dbUser = "sa";
configurable string dbPassword = "";
configurable int port = 8080;

service / on new http:Listener(port) {
    private final db:DbClient dbClient;
    private final repos:OwnerRepository ownerRepo;
    private final repos:PetRepository petRepo;
    private final repos:VisitRepository visitRepo;

    function init() returns error? {
        self.dbClient = check new (dbHost, dbUser, dbPassword);
        self.ownerRepo = new (self.dbClient.getClient());
        self.petRepo = new (self.dbClient.getClient());
        self.visitRepo = new (self.dbClient.getClient());
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
    resource function post pets(@http:Payload types:Pet payload) returns types:Pet|error {
        return self.petRepo.create(payload);
    }

    resource function get pets/[int id]() returns types:Pet|http:NotFound|error {
        types:Pet|error result = self.petRepo.getById(id);
        if result is error {
            return http:NOT_FOUND;
        }
        return result;
    }

    resource function get owners/[int id]/pets() returns types:Pet[]|error {
        return self.petRepo.getByOwnerId(id);
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
}

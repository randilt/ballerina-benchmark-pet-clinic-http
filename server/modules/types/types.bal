import ballerina/time;

public type Owner record {|
    int? id = ();
    string firstName;
    string lastName;
    string address;
    string city;
    string telephone;
|};

public type Pet record {|
    int? id = ();
    string name;
    string species;
    int ownerId;
    string birthDate;
|};

public type Vet record {|
    int? id = ();
    string firstName;
    string lastName;
    Specialty[] specialties;
|};

public type Visit record {|
    int? id = ();
    int petId;
    int vetId;
    string visitDate;
    string description;
|};

public type Appointment record {|
    int? id = ();
    int petId;
    int vetId;
    string dateTime;
    string status;
    string notes;
|};

public type Specialty record {|
    int? id = ();
    string? name;
|};

public type ErrorResponse record {|
    string message;
    string timestamp = time:utcToString(time:utcNow());
    int status;
|};


export interface Pet {
  id: number;
  name: string;
  species: string;
  ownerId: number;
  birthDate: string;
}

export interface Specialty {
  id: number;
  name: string;
}

export interface Vet {
  id: number;
  firstName: string;
  lastName: string;
  specialties: Specialty[];
}

export interface Owner {
  id: number;
  firstName: string;
  lastName: string;
  address: string;
  city: string;
  telephone: string;
}

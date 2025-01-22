import axios from "axios";

const API_URL = "http://localhost:8080";

export async function getPet(id: number) {
  const response = await axios.get(`${API_URL}/pets/${id}`);
  return response.data;
}

export async function getPets() {
  const response = await axios.get(`${API_URL}/pets`);
  return response.data;
}

export async function createPet(pet: any) {
  const response = await axios.post(`${API_URL}/pets`, pet);
  return response.data;
}

export async function updatePet(id: number, pet: any) {
  const response = await axios.put(`${API_URL}/pets/${id}`, pet);
  return response.data;
}

export async function deletePet(id: number) {
  await axios.delete(`${API_URL}/pets/${id}`);
}

export async function getSpecialties() {
  const response = await axios.get(`${API_URL}/specialties`);
  return response.data;
}

export async function createSpecialty(specialty: any) {
  const response = await axios.post(`${API_URL}/specialties`, specialty);
  return response.data;
}

export async function updateSpecialty(id: number, specialty: any) {
  const response = await axios.put(`${API_URL}/specialties/${id}`, specialty);
  return response.data;
}

export async function deleteSpecialty(id: number) {
  await axios.delete(`${API_URL}/specialties/${id}`);
}

export async function getVets() {
  const response = await axios.get(`${API_URL}/vets`);
  return response.data;
}

export async function createVet(vet: any) {
  const response = await axios.post(`${API_URL}/vets`, vet);
  return response.data;
}

export async function updateVet(id: number, vet: any) {
  const response = await axios.put(`${API_URL}/vets/${id}`, vet);
  return response.data;
}

export async function deleteVet(id: number) {
  await axios.delete(`${API_URL}/vets/${id}`);
}

export async function getVet(id: number) {
  const response = await axios.get(`${API_URL}/vets/${id}`);
  return response.data;
}

export async function getOwners() {
  const response = await axios.get(`${API_URL}/owners`);
  return response.data;
}

export async function createOwner(owner: any) {
  const response = await axios.post(`${API_URL}/owners`, owner);
  return response.data;
}

export async function updateOwner(id: number, owner: any) {
  const response = await axios.put(`${API_URL}/owners/${id}`, owner);
  return response.data;
}

export async function deleteOwner(id: number) {
  await axios.delete(`${API_URL}/owners/${id}`);
}

"use server";

import { revalidatePath } from "next/cache";
import { createPet, updatePet, deletePet, getPet } from "@/lib/api";

export async function createPetAction(data: any) {
  try {
    await createPet(data);
    revalidatePath("/pets");
    return { success: true };
  } catch (error) {
    return { success: false, error: "Failed to create pet" };
  }
}

export async function updatePetAction(id: number, data: any) {
  try {
    await updatePet(id, data);
    revalidatePath("/pets");
    return { success: true };
  } catch (error) {
    return { success: false, error: "Failed to update pet" };
  }
}

export async function deletePetAction(id: number) {
  try {
    await deletePet(id);
    revalidatePath("/pets");
    return { success: true };
  } catch (error) {
    return { success: false, error: "Failed to delete pet" };
  }
}

export async function getPetAction(id: number) {
  try {
    const pet = await getPet(id);
    return { success: true, data: pet };
  } catch (error) {
    return { success: false, error: "Failed to fetch pet data" };
  }
}

"use server";

import { revalidatePath } from "next/cache";
import { createVet, updateVet, deleteVet, getVet } from "@/lib/api";

export async function createVetAction(data: any) {
  try {
    await createVet(data);
    revalidatePath("/vets");
    return { success: true };
  } catch (error) {
    return { success: false, error: "Failed to create veterinarian" };
  }
}

export async function updateVetAction(id: number, data: any) {
  try {
    await updateVet(id, data);
    revalidatePath("/vets");
    return { success: true };
  } catch (error) {
    return { success: false, error: "Failed to update veterinarian" };
  }
}

export async function deleteVetAction(id: number) {
  try {
    await deleteVet(id);
    revalidatePath("/vets");
    return { success: true };
  } catch (error) {
    return { success: false, error: "Failed to delete veterinarian" };
  }
}

export async function getVetAction(id: number) {
  try {
    const vet = await getVet(id);
    return { success: true, data: vet };
  } catch (error) {
    return { success: false, error: "Failed to fetch veterinarian data" };
  }
}

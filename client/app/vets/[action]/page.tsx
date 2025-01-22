"use client";

import { useState, useEffect, use } from "react";
import { useRouter } from "next/navigation";
import { useForm, Controller } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import * as z from "zod";
import { getSpecialties } from "@/lib/api";
import { Button } from "@/components/ui/button";
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form";
import { Input } from "@/components/ui/input";
import { useToast } from "@/hooks/use-toast";
import { MultiSelect } from "@/components/ui/multi-select";
import type { PageProps, Specialty } from "@/types";
import {
  createVetAction,
  updateVetAction,
  deleteVetAction,
  getVetAction,
} from "../actions";
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
  AlertDialogTrigger,
} from "@/components/ui/alert-dialog";

const formSchema = z.object({
  firstName: z.string().min(1, "First name is required"),
  lastName: z.string().min(1, "Last name is required"),
  specialties: z
    .array(
      z.object({
        id: z.number(),
        name: z.string(),
      })
    )
    .min(1, "At least one specialty is required"),
});

export default function VetForm({ params }: any) {
  const router = useRouter();
  const action = params.action as string;
  const { toast } = useToast();
  const [isLoading, setIsLoading] = useState(false);
  const [specialties, setSpecialties] = useState([]);
  const isEditing = action !== "new";

  const form = useForm<z.infer<typeof formSchema>>({
    resolver: zodResolver(formSchema),
    defaultValues: {
      firstName: "",
      lastName: "",
      specialties: [],
    },
  });

  useEffect(() => {
    const fetchSpecialties = async () => {
      const fetchedSpecialties = await getSpecialties();
      setSpecialties(
        fetchedSpecialties.map((s: Specialty) => ({
          value: s.id,
          label: s.name,
        }))
      );
    };
    fetchSpecialties();

    if (isEditing) {
      const fetchVetData = async () => {
        const result = await getVetAction(Number(action));
        if (result.success) {
          form.reset({
            firstName: result.data.firstName,
            lastName: result.data.lastName,
            specialties: result.data.specialties,
          });
        } else {
          toast({
            title: "Error",
            description: result.error,
            variant: "destructive",
          });
        }
      };
      fetchVetData();
    }
  }, [isEditing, action, form, toast]);

  async function onSubmit(values: z.infer<typeof formSchema>) {
    setIsLoading(true);
    try {
      const result = isEditing
        ? await updateVetAction(Number(action), values)
        : await createVetAction(values);

      if (result.success) {
        toast({
          title: `Veterinarian ${
            isEditing ? "updated" : "created"
          } successfully`,
          description: `The veterinarian has been ${
            isEditing ? "updated in" : "added to"
          } the system.`,
        });
        router.push("/vets");
      } else {
        throw new Error(result.error);
      }
    } catch (error: any) {
      toast({
        title: "Error",
        description:
          error.message || "An error occurred while saving the veterinarian.",
        variant: "destructive",
      });
    } finally {
      setIsLoading(false);
    }
  }

  async function onDelete() {
    setIsLoading(true);
    try {
      const result = await deleteVetAction(Number(action));
      if (result.success) {
        toast({
          title: "Veterinarian deleted successfully",
          description: "The veterinarian has been removed from the system.",
        });
        router.push("/vets");
      } else {
        throw new Error(result.error);
      }
    } catch (error: any) {
      toast({
        title: "Error",
        description:
          error.message || "An error occurred while deleting the veterinarian.",
        variant: "destructive",
      });
    } finally {
      setIsLoading(false);
    }
  }

  return (
    <div>
      <h1 className="text-3xl font-bold mb-6">
        {isEditing ? "Edit Veterinarian" : "Add New Veterinarian"}
      </h1>
      <Form {...form}>
        <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-8">
          <FormField
            control={form.control}
            name="firstName"
            render={({ field }) => (
              <FormItem>
                <FormLabel>First Name</FormLabel>
                <FormControl>
                  <Input placeholder="First name" {...field} />
                </FormControl>
                <FormMessage />
              </FormItem>
            )}
          />
          <FormField
            control={form.control}
            name="lastName"
            render={({ field }) => (
              <FormItem>
                <FormLabel>Last Name</FormLabel>
                <FormControl>
                  <Input placeholder="Last name" {...field} />
                </FormControl>
                <FormMessage />
              </FormItem>
            )}
          />
          <FormField
            control={form.control}
            name="specialties"
            render={({ field }) => (
              <FormItem>
                <FormLabel>Specialties</FormLabel>
                <FormControl>
                  <Controller
                    name="specialties"
                    control={form.control}
                    render={({ field }) => (
                      <MultiSelect
                        options={specialties}
                        {...field}
                        onChange={(val: any) =>
                          field.onChange(
                            val.map((v: any) => ({
                              id: v.value,
                              name: v.label,
                            }))
                          )
                        }
                        selected={specialties.filter((option: any) =>
                          field.value.some(
                            (specialty: any) => specialty.id === option.value
                          )
                        )}
                      />
                    )}
                  />
                </FormControl>
                <FormMessage />
              </FormItem>
            )}
          />
          <div className="flex justify-between">
            <Button type="submit" disabled={isLoading}>
              {isLoading ? "Saving..." : "Save Veterinarian"}
            </Button>
            {isEditing && (
              <AlertDialog>
                <AlertDialogTrigger asChild>
                  <Button variant="destructive" disabled={isLoading}>
                    Delete Veterinarian
                  </Button>
                </AlertDialogTrigger>
                <AlertDialogContent>
                  <AlertDialogHeader>
                    <AlertDialogTitle>Are you sure?</AlertDialogTitle>
                    <AlertDialogDescription>
                      This action cannot be undone. This will permanently delete
                      the veterinarian from the system.
                    </AlertDialogDescription>
                  </AlertDialogHeader>
                  <AlertDialogFooter>
                    <AlertDialogCancel>Cancel</AlertDialogCancel>
                    <AlertDialogAction onClick={onDelete}>
                      Delete
                    </AlertDialogAction>
                  </AlertDialogFooter>
                </AlertDialogContent>
              </AlertDialog>
            )}
          </div>
        </form>
      </Form>
    </div>
  );
}

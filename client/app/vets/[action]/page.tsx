"use client";

import { useState, useEffect, use } from "react";
import { useRouter } from "next/navigation";
import { useForm, Controller } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import * as z from "zod";
import { createVet, updateVet, getSpecialties } from "@/lib/api";
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
import { Specialty } from "@/types";

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

export default function VetForm({ params }: { params: { action: string } }) {
  const router = useRouter();
  const resolvedParams = use(params as any);
  const action = (resolvedParams as { action: string }).action;
  const { toast } = useToast();
  const [isLoading, setIsLoading] = useState(false);
  const [specialties, setSpecialties] = useState([]);

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
  }, []);

  const form = useForm<z.infer<typeof formSchema>>({
    resolver: zodResolver(formSchema),
    defaultValues: {
      firstName: "",
      lastName: "",
      specialties: [],
    },
  });

  async function onSubmit(values: z.infer<typeof formSchema>) {
    setIsLoading(true);
    try {
      if (action === "new") {
        await createVet(values);
        toast({
          title: "Veterinarian created successfully",
          description: "The new veterinarian has been added to the system.",
        });
      } else if (action === "edit") {
        await updateVet(Number.parseInt(action), values);
        toast({
          title: "Veterinarian updated successfully",
          description: "The veterinarian information has been updated.",
        });
      }
      router.push("/vets");
    } catch (error) {
      toast({
        title: "Error",
        description: "An error occurred while saving the veterinarian.",
        variant: "destructive",
      });
    } finally {
      setIsLoading(false);
    }
  }

  return (
    <div>
      <h1 className="text-3xl font-bold mb-6">
        {action === "new" ? "Add New Veterinarian" : "Edit Veterinarian"}
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
          <Button type="submit" disabled={isLoading}>
            {isLoading ? "Saving..." : "Save Veterinarian"}
          </Button>
        </form>
      </Form>
    </div>
  );
}

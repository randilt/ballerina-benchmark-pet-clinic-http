"use client";

import { use, useState } from "react";
import { useRouter } from "next/navigation";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import * as z from "zod";
import { createSpecialty, updateSpecialty } from "@/lib/api";
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

const formSchema = z.object({
  name: z.string().min(1, "Name is required"),
});

export default function SpecialtyForm({
  params,
}: {
  params: { action: string };
}) {
  const router = useRouter();
  const resolvedParams = use(params as any);
  const action = (resolvedParams as { action: string }).action;
  const { toast } = useToast();
  const [isLoading, setIsLoading] = useState(false);

  const form = useForm<z.infer<typeof formSchema>>({
    resolver: zodResolver(formSchema),
    defaultValues: {
      name: "",
    },
  });

  async function onSubmit(values: z.infer<typeof formSchema>) {
    setIsLoading(true);
    try {
      if (action === "new") {
        await createSpecialty(values);
        toast({
          title: "Specialty created successfully",
          description: "The new specialty has been added to the system.",
        });
      } else if (action === "edit") {
        await updateSpecialty(Number.parseInt(action), values);
        toast({
          title: "Specialty updated successfully",
          description: "The specialty information has been updated.",
        });
      }
      router.push("/specialties");
    } catch (error) {
      toast({
        title: "Error",
        description: "An error occurred while saving the specialty.",
        variant: "destructive",
      });
    } finally {
      setIsLoading(false);
    }
  }

  return (
    <div>
      <h1 className="text-3xl font-bold mb-6">
        {action === "new" ? "Add New Specialty" : "Edit Specialty"}
      </h1>
      <Form {...form}>
        <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-8">
          <FormField
            control={form.control}
            name="name"
            render={({ field }) => (
              <FormItem>
                <FormLabel>Name</FormLabel>
                <FormControl>
                  <Input placeholder="Specialty name" {...field} />
                </FormControl>
                <FormMessage />
              </FormItem>
            )}
          />
          <Button type="submit" disabled={isLoading}>
            {isLoading ? "Saving..." : "Save Specialty"}
          </Button>
        </form>
      </Form>
    </div>
  );
}

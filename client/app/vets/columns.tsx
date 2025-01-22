"use client";

import type { ColumnDef } from "@tanstack/react-table";
import { Button } from "@/components/ui/button";
import Link from "next/link";
import type { Vet } from "@/types";

export const columns: ColumnDef<Vet>[] = [
  {
    accessorKey: "firstName",
    header: "First Name",
  },
  {
    accessorKey: "lastName",
    header: "Last Name",
  },
  {
    accessorKey: "specialties",
    header: "Specialties",
    cell: ({ row }) => {
      const specialties = row.original.specialties;
      return <span>{specialties.map((s) => s.name).join(", ")}</span>;
    },
  },
  {
    id: "actions",
    cell: ({ row }) => {
      const vet = row.original;

      return (
        <div className="flex">
          <Link href={`/vets/${vet.id}`}>
            <Button variant="outline" size="sm">
              Update
            </Button>
          </Link>
        </div>
      );
    },
  },
];

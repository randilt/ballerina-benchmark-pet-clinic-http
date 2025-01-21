"use client";

import type { ColumnDef } from "@tanstack/react-table";
import { Button } from "@/components/ui/button";
import Link from "next/link";
import type { Pet } from "@/types";

export const columns: ColumnDef<Pet>[] = [
  {
    accessorKey: "name",
    header: "Name",
  },
  {
    accessorKey: "species",
    header: "Species",
  },
  {
    accessorKey: "birthDate",
    header: "Birth Date",
  },
  {
    id: "actions",
    cell: ({ row }) => {
      const pet = row.original;

      return (
        <div className="flex space-x-2">
          <Link href={`/pets/${pet.id}/edit`}>
            <Button variant="outline" size="sm">
              Edit
            </Button>
          </Link>
          <Link href={`/pets/${pet.id}/delete`}>
            <Button variant="destructive" size="sm">
              Delete
            </Button>
          </Link>
        </div>
      );
    },
  },
];

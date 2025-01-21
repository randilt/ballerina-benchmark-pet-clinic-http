"use client";

import type { ColumnDef } from "@tanstack/react-table";
import { Button } from "@/components/ui/button";
import Link from "next/link";
import type { Specialty } from "@/types";

export const columns: ColumnDef<Specialty>[] = [
  {
    accessorKey: "name",
    header: "Name",
  },
  {
    id: "actions",
    cell: ({ row }) => {
      const specialty = row.original;

      return (
        <div className="flex space-x-2">
          <Link href={`/specialties/${specialty.id}/edit`}>
            <Button variant="outline" size="sm">
              Edit
            </Button>
          </Link>
          <Link href={`/specialties/${specialty.id}/delete`}>
            <Button variant="destructive" size="sm">
              Delete
            </Button>
          </Link>
        </div>
      );
    },
  },
];

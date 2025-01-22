"use client";

import type { ColumnDef } from "@tanstack/react-table";
import { Button } from "@/components/ui/button";
import Link from "next/link";
import type { Owner } from "@/types";

export const columns: ColumnDef<Owner>[] = [
  {
    accessorKey: "firstName",
    header: "First Name",
  },
  {
    accessorKey: "lastName",
    header: "Last Name",
  },
  {
    accessorKey: "address",
    header: "Address",
  },
  {
    accessorKey: "city",
    header: "City",
  },
  {
    accessorKey: "telephone",
    header: "Telephone",
  },
  {
    id: "actions",
    cell: ({ row }) => {
      const owner = row.original;

      return (
        <div className="flex space-x-2">
          <Link href={`/owners/${owner.id}/edit`}>
            <Button variant="outline" size="sm">
              Edit
            </Button>
          </Link>
          <Link href={`/owners/${owner.id}/delete`}>
            <Button variant="destructive" size="sm">
              Delete
            </Button>
          </Link>
        </div>
      );
    },
  },
];

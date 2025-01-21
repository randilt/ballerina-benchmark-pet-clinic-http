import { getPets } from "@/lib/api";
import { DataTable } from "./data-table";
import { columns } from "./columns";
import Link from "next/link";
import { Button } from "@/components/ui/button";

export default async function PetsPage() {
  const pets = await getPets();

  return (
    <div>
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-3xl font-bold">Pets</h1>
        <Link href="/pets/new">
          <Button>Add New Pet</Button>
        </Link>
      </div>
      <DataTable columns={columns} data={pets} />
    </div>
  );
}

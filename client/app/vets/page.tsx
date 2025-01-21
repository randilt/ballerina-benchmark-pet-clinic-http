import { getVets } from "@/lib/api";
import { DataTable } from "./data-table";
import { columns } from "./columns";
import Link from "next/link";
import { Button } from "@/components/ui/button";

export default async function VetsPage() {
  const vets = await getVets();

  return (
    <div>
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-3xl font-bold">Veterinarians</h1>
        <Link href="/vets/new">
          <Button>Add New Vet</Button>
        </Link>
      </div>
      <DataTable columns={columns} data={vets} />
    </div>
  );
}

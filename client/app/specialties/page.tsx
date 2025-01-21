import { getSpecialties } from "@/lib/api";
import { DataTable } from "./data-table";
import { columns } from "./columns";
import Link from "next/link";
import { Button } from "@/components/ui/button";

export default async function SpecialtiesPage() {
  const specialties = await getSpecialties();

  return (
    <div>
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-3xl font-bold">Specialties</h1>
        <Link href="/specialties/new">
          <Button>Add New Specialty</Button>
        </Link>
      </div>
      <DataTable columns={columns} data={specialties} />
    </div>
  );
}

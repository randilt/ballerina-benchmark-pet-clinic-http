import { getOwners } from "@/lib/api";
import { DataTable } from "./data-table";
import { columns } from "./columns";
import Link from "next/link";
import { Button } from "@/components/ui/button";

export default async function OwnersPage() {
  const owners = await getOwners();

  return (
    <div>
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-3xl font-bold">Pet Owners</h1>
        <Link href="/owners/new">
          <Button>Add New Owner</Button>
        </Link>
      </div>
      <DataTable columns={columns} data={owners} />
    </div>
  );
}

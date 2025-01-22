import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { getOwners, getPets, getSpecialties, getVets } from "@/lib/api";

export default async function Home() {
  const [pets, specialties, vets, owners] = await Promise.all([
    getPets(),
    getSpecialties(),
    getVets(),
    getOwners(),
  ]);

  return (
    <div>
      <h1 className="text-3xl font-bold mb-6">Dashboard</h1>
      <div className="grid gap-4 md:grid-cols-3">
        <Card>
          <CardHeader>
            <CardTitle>Total Pets</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-4xl font-bold">{pets.length}</p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader>
            <CardTitle>Total Specialties</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-4xl font-bold">{specialties.length}</p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader>
            <CardTitle>Total Vets</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-4xl font-bold">{vets.length}</p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader>
            <CardTitle>Total Owners</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-4xl font-bold">{owners.length}</p>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}

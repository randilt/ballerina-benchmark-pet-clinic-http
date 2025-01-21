import Link from "next/link";
import { ModeToggle } from "./mode-toggle";

export function Navbar() {
  return (
    <nav className="border-b">
      <div className="container mx-auto flex items-center justify-between py-4 px-4">
        <Link href="/" className="text-2xl font-bold">
          PetClinic
        </Link>
        <div className="flex items-center space-x-4">
          <Link href="/pets" className="hover:underline">
            Pets
          </Link>
          <Link href="/specialties" className="hover:underline">
            Specialties
          </Link>
          <Link href="/vets" className="hover:underline">
            Vets
          </Link>
          <ModeToggle />
        </div>
      </div>
    </nav>
  );
}

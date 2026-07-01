"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import Mascot from "./Mascot";
import ThemeToggle from "./ThemeToggle";

const links = [
  { href: "/", label: "Today" },
  { href: "/curriculum", label: "Curriculum" },
  { href: "/progress", label: "Progress" },
  { href: "/archive", label: "Archive" },
  { href: "/news", label: "News" },
];

export default function Nav() {
  const pathname = usePathname();
  const isActive = (href: string) => (href === "/" ? pathname === "/" : pathname.startsWith(href));

  return (
    <header className="border-b border-edge bg-nav">
      <div className="mx-auto flex h-16 max-w-5xl items-center gap-2 px-4 sm:px-7">
        <Link href="/" className="mr-5 flex items-center gap-2.5">
          <Mascot size={30} />
          <span className="font-display text-xl font-semibold tracking-tight text-head">Sensei</span>
        </Link>
        <nav className="flex gap-1">
          {links.map((l) => {
            const active = isActive(l.href);
            return (
              <Link
                key={l.href}
                href={l.href}
                className={`rounded-lg px-3 py-1.5 text-sm font-semibold transition-colors ${
                  active ? "bg-teal-soft text-head" : "text-muted hover:text-head"
                }`}
              >
                {l.label}
              </Link>
            );
          })}
        </nav>
        <div className="ml-auto">
          <ThemeToggle />
        </div>
      </div>
    </header>
  );
}

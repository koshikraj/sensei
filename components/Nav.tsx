"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useState } from "react";
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
  const [open, setOpen] = useState(false);
  const isActive = (href: string) => (href === "/" ? pathname === "/" : pathname.startsWith(href));

  return (
    <header className="border-b border-edge bg-nav">
      <div className="mx-auto flex h-16 max-w-5xl items-center gap-2 px-4 sm:px-7">
        <Link
          href="/"
          className="flex items-center gap-2.5 sm:mr-5"
          onClick={() => setOpen(false)}
        >
          <Mascot size={30} />
          <span className="font-display text-xl font-semibold tracking-tight text-head">Sensei</span>
        </Link>
        <nav className="hidden gap-1 sm:flex">
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
        <div className="ml-auto flex items-center gap-2">
          <ThemeToggle />
          <button
            type="button"
            onClick={() => setOpen((o) => !o)}
            aria-label="Toggle navigation menu"
            aria-expanded={open}
            className="grid h-9 w-9 flex-none place-items-center rounded-lg border border-edge text-head transition-colors hover:bg-track/40 sm:hidden"
          >
            <svg className="h-5 w-5" viewBox="0 0 24 24" fill="none" aria-hidden>
              {open ? (
                <path d="M6 6l12 12M18 6L6 18" stroke="currentColor" strokeWidth="2" strokeLinecap="round" />
              ) : (
                <path d="M4 7h16M4 12h16M4 17h16" stroke="currentColor" strokeWidth="2" strokeLinecap="round" />
              )}
            </svg>
          </button>
        </div>
      </div>
      {open && (
        <nav className="flex flex-col gap-1 border-t border-edge px-4 pb-3 pt-2 sm:hidden">
          {links.map((l) => {
            const active = isActive(l.href);
            return (
              <Link
                key={l.href}
                href={l.href}
                onClick={() => setOpen(false)}
                className={`rounded-lg px-3 py-2.5 text-sm font-semibold transition-colors ${
                  active ? "bg-teal-soft text-head" : "text-muted hover:text-head"
                }`}
              >
                {l.label}
              </Link>
            );
          })}
        </nav>
      )}
    </header>
  );
}

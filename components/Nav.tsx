import Link from "next/link";

const links = [
  { href: "/", label: "Today" },
  { href: "/curriculum", label: "Curriculum" },
  { href: "/progress", label: "Progress" },
  { href: "/archive", label: "Archive" },
  { href: "/news", label: "News" },
];

export default function Nav() {
  return (
    <header className="border-b border-edge bg-panel">
      <div className="mx-auto max-w-5xl flex items-center gap-6 px-4 h-14">
        <Link href="/" className="font-semibold text-white">
          🥋 Sensei
        </Link>
        <nav className="flex gap-4 text-sm text-muted">
          {links.map((l) => (
            <Link key={l.href} href={l.href} className="hover:text-white transition-colors">
              {l.label}
            </Link>
          ))}
        </nav>
      </div>
    </header>
  );
}

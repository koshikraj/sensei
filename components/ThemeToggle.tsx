"use client";

import { useEffect, useState } from "react";

type Theme = "light" | "dark";

export default function ThemeToggle() {
  const [theme, setTheme] = useState<Theme>("light");

  useEffect(() => {
    const current = (document.documentElement.getAttribute("data-theme") as Theme) || "light";
    setTheme(current);
  }, []);

  function apply(next: Theme) {
    setTheme(next);
    document.documentElement.setAttribute("data-theme", next);
    try {
      localStorage.setItem("sensei-theme", next);
    } catch {
      /* ignore */
    }
  }

  return (
    <div className="flex items-center gap-0.5 rounded-xl border border-edge bg-nav p-1">
      {(["light", "dark"] as Theme[]).map((t) => {
        const active = theme === t;
        return (
          <button
            key={t}
            onClick={() => apply(t)}
            className={`rounded-lg px-3 py-1.5 text-xs font-extrabold capitalize transition-colors ${
              active ? "bg-teal text-on-teal" : "text-muted hover:text-head"
            }`}
          >
            {t}
          </button>
        );
      })}
    </div>
  );
}

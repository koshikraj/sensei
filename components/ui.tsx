import { ReactNode } from "react";

export function Card({ children, className = "" }: { children: ReactNode; className?: string }) {
  return (
    <div className={`rounded-xl border border-edge bg-panel p-5 ${className}`}>{children}</div>
  );
}

export function SectionTitle({ children }: { children: ReactNode }) {
  return <h2 className="text-sm font-medium uppercase tracking-wide text-muted mb-3">{children}</h2>;
}

export function Badge({ children }: { children: ReactNode }) {
  return (
    <span className="inline-block rounded-full border border-edge bg-ink px-2 py-0.5 text-xs text-muted">
      {children}
    </span>
  );
}

export function EmptyState({ title, hint }: { title: string; hint?: string }) {
  return (
    <div className="rounded-xl border border-dashed border-edge bg-panel/50 p-8 text-center">
      <p className="text-gray-300">{title}</p>
      {hint && <p className="mt-1 text-sm text-muted">{hint}</p>}
    </div>
  );
}

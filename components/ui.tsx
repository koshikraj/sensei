import { ReactNode } from "react";

export function Card({
  children,
  className = "",
  elevated = false,
}: {
  children: ReactNode;
  className?: string;
  elevated?: boolean;
}) {
  return (
    <div
      className={`rounded-xl2 border border-edge bg-surface p-5 ${elevated ? "shadow-card" : ""} ${className}`}
    >
      {children}
    </div>
  );
}

export function SectionTitle({ children }: { children: ReactNode }) {
  return (
    <h2 className="mb-3 text-xs font-bold uppercase tracking-[0.09em] text-teal">{children}</h2>
  );
}

export function Badge({ children, tone = "neutral" }: { children: ReactNode; tone?: "neutral" | "teal" | "indigo" }) {
  const tones = {
    neutral: "border border-edge bg-track text-muted",
    teal: "bg-teal-soft text-teal",
    indigo: "bg-indigo-soft text-indigo",
  } as const;
  return (
    <span className={`inline-block rounded-full px-2.5 py-1 text-xs font-semibold ${tones[tone]}`}>
      {children}
    </span>
  );
}

export function EmptyState({ title, hint }: { title: string; hint?: string }) {
  return (
    <div className="rounded-xl2 border border-dashed border-edge bg-surface/50 p-8 text-center">
      <p className="text-body">{title}</p>
      {hint && <p className="mt-1 text-sm text-muted">{hint}</p>}
    </div>
  );
}

export function PageHeader({
  title,
  subtitle,
  right,
}: {
  title: string;
  subtitle?: string;
  right?: ReactNode;
}) {
  return (
    <div className="flex flex-wrap items-start justify-between gap-4">
      <div>
        <h1 className="font-display text-3xl font-semibold tracking-tight text-head">{title}</h1>
        {subtitle && <p className="mt-1.5 text-[15px] text-muted">{subtitle}</p>}
      </div>
      {right}
    </div>
  );
}

export function MasteryRing({ value }: { value: number }) {
  return (
    <div className="flex items-center gap-3.5">
      <div className="text-right">
        <div className="font-display text-2xl font-semibold leading-none text-head">{value}%</div>
        <div className="mt-1 text-[11px] uppercase tracking-[0.08em] text-faint">avg mastery</div>
      </div>
      <div
        className="grid h-[60px] w-[60px] flex-none place-items-center rounded-full"
        style={{ background: `conic-gradient(var(--teal) ${value * 3.6}deg, var(--track) 0)` }}
      >
        <div className="h-11 w-11 rounded-full bg-canvas" />
      </div>
    </div>
  );
}

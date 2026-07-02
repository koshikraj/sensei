import { Card, Badge, EmptyState, PageHeader } from "@/components/ui";
import { getCurriculum } from "@/lib/queries";

export const revalidate = 300;

const statusTone: Record<string, "teal" | "indigo" | "neutral"> = {
  done: "teal",
  "in progress": "indigo",
  upcoming: "neutral",
};

const lessonMark: Record<string, string> = { completed: "✓", available: "•", planned: "·" };

export default async function CurriculumPage() {
  const modules = await getCurriculum();

  return (
    <div className="space-y-6">
      <PageHeader title="Curriculum" subtitle="Modules → topics → lessons. Click a topic to see its lessons — advance by finishing each topic." />

      {modules.length === 0 ? (
        <EmptyState title="Curriculum not loaded." hint="Run npm run db:setup to populate the plan." />
      ) : (
        modules.map((m) => (
          <div key={m.seq}>
            <div className="mb-3 flex items-center gap-3">
              <div className="grid h-11 w-11 flex-none place-items-center rounded-[13px] bg-teal-soft font-display text-lg font-semibold text-teal">
                {m.seq}
              </div>
              <h3 className="font-display text-lg font-semibold text-head">{m.title}</h3>
            </div>
            <Card className="divide-y divide-edge p-0">
              {m.topics.map((t) => {
                const done = t.lessons.filter((l) => l.status === "completed").length;
                return (
                  <details key={t.seq} className="group" open={t.status === "in progress"}>
                    <summary className="flex cursor-pointer select-none list-none items-center gap-3 px-4 py-3 hover:bg-track/40 [&::-webkit-details-marker]:hidden">
                      <svg
                        className="h-3.5 w-3.5 flex-none text-faint transition-transform group-open:rotate-90"
                        viewBox="0 0 16 16"
                        fill="none"
                        aria-hidden
                      >
                        <path d="M6 4l4 4-4 4" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" />
                      </svg>
                      <span className="min-w-0 flex-1 truncate text-body">{t.title}</span>
                      <span className="flex-none whitespace-nowrap text-xs text-faint">
                        {done > 0 ? `${done}/${t.lessons.length} lessons` : `${t.lessons.length} lessons`}
                      </span>
                      <span className="flex-none">
                        <Badge tone={statusTone[t.status] ?? "neutral"}>{t.status}</Badge>
                      </span>
                    </summary>
                    <div className="border-t border-edge bg-track/20 py-1">
                      {t.lessons.length ? (
                        t.lessons.map((l) => (
                          <div key={l.position} className="flex items-center gap-3 py-2 pl-11 pr-4">
                            <span className={`w-4 flex-none text-center ${l.status === "completed" ? "text-teal" : "text-faint"}`}>
                              {lessonMark[l.status] ?? "·"}
                            </span>
                            <span className={`min-w-0 break-words text-sm ${l.status === "completed" ? "text-head" : "text-body"}`}>{l.title}</span>
                            <span className="ml-auto flex-none">
                              <Badge>{l.format}</Badge>
                            </span>
                          </div>
                        ))
                      ) : (
                        <p className="py-2 pl-11 pr-4 text-sm text-faint">No lessons yet.</p>
                      )}
                    </div>
                  </details>
                );
              })}
            </Card>
          </div>
        ))
      )}
    </div>
  );
}

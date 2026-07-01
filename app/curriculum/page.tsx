import { Card, Badge, EmptyState, PageHeader } from "@/components/ui";
import { getCurriculum } from "@/lib/queries";

export const revalidate = 300;

const statusTone: Record<string, "teal" | "indigo" | "neutral"> = {
  done: "teal",
  "in progress": "indigo",
  upcoming: "neutral",
};

export default async function CurriculumPage() {
  const modules = await getCurriculum();

  return (
    <div className="space-y-6">
      <PageHeader title="Curriculum" subtitle="Modules → topics → lessons. Self-paced — advance by finishing each topic." />

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
              {m.topics.map((t) => (
                <div key={t.seq} className="flex items-center gap-3 px-4 py-3">
                  <span className="text-body">{t.title}</span>
                  <span className="text-xs text-faint">{t.lessons} lessons</span>
                  <span className="ml-auto">
                    <Badge tone={statusTone[t.status] ?? "neutral"}>{t.status}</Badge>
                  </span>
                </div>
              ))}
            </Card>
          </div>
        ))
      )}
    </div>
  );
}

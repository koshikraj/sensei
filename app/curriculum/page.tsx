import { Card, SectionTitle, Badge, EmptyState, PageHeader } from "@/components/ui";
import { getTopics, getLessons } from "@/lib/queries";
import type { Topic } from "@/lib/types";

export const revalidate = 300;

export default async function CurriculumPage() {
  const [topics, lessons] = await Promise.all([getTopics(), getLessons(200)]);
  const doneSeq = new Set(
    lessons.map((l) => topics.find((t) => t.id === l.topic_id)?.seq).filter(Boolean) as number[]
  );

  const byWeek = new Map<number, Topic[]>();
  for (const t of topics) {
    if (!byWeek.has(t.week)) byWeek.set(t.week, []);
    byWeek.get(t.week)!.push(t);
  }

  return (
    <div className="space-y-6">
      <PageHeader title="Curriculum" subtitle="10 weeks · 50 lessons · Beginner → job-ready." />

      {topics.length === 0 ? (
        <EmptyState title="Curriculum not loaded." hint="Run supabase/seed.sql to populate the 50-lesson plan." />
      ) : (
        [...byWeek.entries()].map(([week, ts]) => (
          <div key={week}>
            <div className="mb-3 flex items-center gap-3">
              <div className="grid h-11 w-11 flex-none place-items-center rounded-[13px] bg-teal-soft font-display text-lg font-semibold text-teal">
                {week}
              </div>
              <div>
                <h3 className="font-display text-lg font-semibold text-head">Week {week}</h3>
                <div className="text-[13px] text-muted">{ts[0].module}</div>
              </div>
            </div>
            <Card className="divide-y divide-edge p-0">
              {ts.map((t) => {
                const done = doneSeq.has(t.seq);
                return (
                  <div key={t.id} className="flex items-center gap-3 px-4 py-3">
                    <span className="w-6 text-xs text-faint">{t.seq}</span>
                    <span className={done ? "text-head" : "text-body"}>{t.title}</span>
                    {done && <span className="text-xs text-teal">✓</span>}
                    <span className="ml-auto">
                      <Badge>{t.format}</Badge>
                    </span>
                  </div>
                );
              })}
            </Card>
          </div>
        ))
      )}
    </div>
  );
}

import { Card, SectionTitle, EmptyState, PageHeader, MasteryRing } from "@/components/ui";
import { getProgress } from "@/lib/queries";

export const revalidate = 300;

function scoreColor(score: number) {
  if (score >= 80) return "var(--teal)";
  if (score >= 50) return "#FBBF24";
  if (score > 0) return "#FB7185";
  return "var(--track)";
}

export default async function ProgressPage() {
  const topics = await getProgress();
  const scored = topics.filter((t) => t.mastery > 0);
  const avg = scored.length ? Math.round(scored.reduce((s, t) => s + t.mastery, 0) / scored.length) : 0;
  const weak = topics.filter((t) => t.mastery > 0 && t.mastery < 50).slice(0, 8);

  return (
    <div className="space-y-8">
      <PageHeader title="Progress" subtitle="Mastery across every topic." right={<MasteryRing value={avg} />} />

      {topics.length === 0 ? (
        <EmptyState title="No data yet." hint="Progress fills in as you complete topics and quizzes." />
      ) : (
        <>
          <section>
            <SectionTitle>Topic mastery</SectionTitle>
            <Card>
              <div className="flex flex-wrap gap-1.5">
                {topics.map((t, i) => (
                  <div
                    key={i}
                    title={`${t.title} — ${t.mastery}%`}
                    className="h-7 w-7 rounded-md"
                    style={{ background: scoreColor(t.mastery) }}
                  />
                ))}
              </div>
              <p className="mt-3 text-xs text-faint">Each square is a topic, in order. Hover for details.</p>
            </Card>
          </section>

          <section>
            <SectionTitle>Focus next</SectionTitle>
            {weak.length === 0 ? (
              <EmptyState title="No weak topics — nice." />
            ) : (
              <Card className="divide-y divide-edge p-0">
                {weak.map((t, i) => (
                  <div key={i} className="flex items-center justify-between px-4 py-3">
                    <span className="text-body">{t.title}</span>
                    <span className="text-sm font-bold" style={{ color: "#FB7185" }}>
                      {t.mastery}%
                    </span>
                  </div>
                ))}
              </Card>
            )}
          </section>
        </>
      )}
    </div>
  );
}

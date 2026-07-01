import { Card, SectionTitle, EmptyState } from "@/components/ui";
import { getTopics, getMastery } from "@/lib/queries";

export const revalidate = 300;

function scoreColor(score: number) {
  if (score >= 80) return "bg-green-500/80";
  if (score >= 50) return "bg-yellow-500/70";
  if (score > 0) return "bg-orange-500/70";
  return "bg-edge";
}

export default async function ProgressPage() {
  const [topics, mastery] = await Promise.all([getTopics(), getMastery()]);
  const byTopic = new Map(mastery.map((m) => [m.topic_id, m]));

  const avg =
    mastery.length > 0
      ? Math.round(mastery.reduce((s, m) => s + m.score, 0) / mastery.length)
      : 0;
  const weak = topics
    .map((t) => ({ t, m: byTopic.get(t.id) }))
    .filter((x) => x.m && x.m.score > 0 && x.m.score < 50)
    .slice(0, 8);

  return (
    <div className="space-y-8">
      <div className="flex items-end justify-between">
        <div>
          <h1 className="text-2xl font-semibold text-white">Progress</h1>
          <p className="text-muted text-sm mt-1">Mastery across all 50 topics.</p>
        </div>
        <div className="text-right">
          <div className="text-3xl font-semibold text-white">{avg}%</div>
          <div className="text-xs text-muted">avg mastery</div>
        </div>
      </div>

      {topics.length === 0 ? (
        <EmptyState title="No data yet." hint="Progress fills in as you take daily quizzes." />
      ) : (
        <>
          <section>
            <SectionTitle>Mastery heatmap</SectionTitle>
            <Card>
              <div className="grid grid-cols-10 gap-1.5">
                {topics.map((t) => {
                  const score = byTopic.get(t.id)?.score ?? 0;
                  return (
                    <div
                      key={t.id}
                      title={`${t.title} — ${score}%`}
                      className={`aspect-square rounded ${scoreColor(score)}`}
                    />
                  );
                })}
              </div>
              <p className="mt-3 text-xs text-muted">Each cell is a topic, in curriculum order. Hover for details.</p>
            </Card>
          </section>

          <section>
            <SectionTitle>Focus next</SectionTitle>
            {weak.length === 0 ? (
              <EmptyState title="No weak topics — nice." />
            ) : (
              <Card className="p-0 divide-y divide-edge">
                {weak.map(({ t, m }) => (
                  <div key={t.id} className="flex items-center justify-between px-4 py-3">
                    <span className="text-gray-300">{t.title}</span>
                    <span className="text-sm text-orange-300">{m!.score}%</span>
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

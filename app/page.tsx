import { Card, SectionTitle, Badge, EmptyState, PageHeader, MasteryRing } from "@/components/ui";
import Mascot from "@/components/Mascot";
import { isConfigured } from "@/lib/supabase";
import { getToday } from "@/lib/queries";

export const revalidate = 300;

const lessonMark: Record<string, string> = { completed: "✓", available: "•", planned: "·" };

const quizLabel: Record<string, string> = {
  locked: "Finish the lessons to unlock the quiz",
  due: "Quiz is due — finish your lessons",
  available: "Quiz ready — answer it in #sensei",
  completed: "Quiz complete ✓",
};

export default async function TodayPage() {
  const { topic, lessons, resources, quizStatus, topicsDone, topicsTotal, avgMastery } = await getToday();

  return (
    <div className="space-y-7">
      <PageHeader
        title="Today"
        subtitle={topicsTotal ? `Topic ${topicsDone + (topic ? 1 : 0)} of ${topicsTotal}` : "Your AI Engineering journey"}
        right={<MasteryRing value={avgMastery} />}
      />

      <div
        className="flex items-center gap-3.5 rounded-xl2 border border-edge px-[18px] py-3.5"
        style={{ background: "linear-gradient(90deg,var(--teal-soft),var(--indigo-soft))" }}
      >
        <Mascot size={40} className="flex-none" />
        <div>
          <div className="text-[15px] font-extrabold text-head">
            {topic ? `Today's topic: ${topic.title}` : "Ready when you are."}
          </div>
          <div className="mt-0.5 text-[13.5px] text-muted">
            {topic ? `${topic.module} · finish the lessons, then take the quiz to complete the topic.` : "Your sensei will start the first topic soon."}
          </div>
        </div>
      </div>

      {!isConfigured() && (
        <EmptyState
          title="Supabase isn't connected yet."
          hint="Set NEXT_PUBLIC_SUPABASE_URL + PUBLISHABLE_KEY, then run npm run db:setup."
        />
      )}

      {topic ? (
        <>
          <section>
            <SectionTitle>Current topic</SectionTitle>
            <Card>
              <Badge tone="teal">{topic.module}</Badge>
              <h2 className="mt-2 font-display text-2xl font-semibold text-head">{topic.title}</h2>
              {topic.description && <p className="mt-2 text-[15px] leading-relaxed text-muted">{topic.description}</p>}
              {topic.objectives && <p className="mt-2 text-sm text-faint">{topic.objectives}</p>}
            </Card>
          </section>

          <div className="grid gap-5 md:grid-cols-2">
            <section>
              <SectionTitle>Lessons</SectionTitle>
              {lessons.length ? (
                <Card className="divide-y divide-edge p-0">
                  {lessons.map((l) => (
                    <div key={l.position} className="flex items-center gap-3 px-4 py-3">
                      <span className={`w-4 flex-none text-center ${l.status === "completed" ? "text-teal" : "text-faint"}`}>
                        {lessonMark[l.status] ?? "·"}
                      </span>
                      <span className={`min-w-0 break-words ${l.status === "completed" ? "text-head" : "text-body"}`}>{l.title}</span>
                      <span className="ml-auto flex-none">
                        <Badge>{l.format}</Badge>
                      </span>
                    </div>
                  ))}
                </Card>
              ) : (
                <EmptyState title="Lessons will appear when the topic starts." />
              )}
            </section>

            <section>
              <SectionTitle>Resources</SectionTitle>
              {resources.length ? (
                <Card className="divide-y divide-edge p-0">
                  {resources.map((r, i) => (
                    <a
                      key={i}
                      href={r.url ?? "#"}
                      target="_blank"
                      rel="noreferrer"
                      className="flex items-center gap-3 px-4 py-3 hover:bg-track/40"
                    >
                      <span className="flex-none">
                        <Badge tone="indigo">{r.kind}</Badge>
                      </span>
                      <span className="min-w-0 break-words text-body">{r.title}</span>
                      {r.source && <span className="ml-auto flex-none text-xs text-faint">{r.source}</span>}
                    </a>
                  ))}
                </Card>
              ) : (
                <EmptyState title="No resources attached yet." />
              )}
            </section>
          </div>

          <section>
            <SectionTitle>Quiz</SectionTitle>
            <Card>
              <div className="flex items-center gap-2">
                <Badge tone={quizStatus === "completed" ? "teal" : quizStatus === "available" ? "indigo" : "neutral"}>
                  {quizStatus}
                </Badge>
                <span className="text-sm text-muted">{quizLabel[quizStatus] ?? ""}</span>
              </div>
            </Card>
          </section>
        </>
      ) : (
        topicsTotal > 0 && <EmptyState title="🎉 Every topic complete!" hint="You've finished the whole curriculum." />
      )}
    </div>
  );
}

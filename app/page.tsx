import { Card, SectionTitle, Badge, EmptyState, PageHeader, MasteryRing } from "@/components/ui";
import Mascot from "@/components/Mascot";
import { isConfigured } from "@/lib/supabase";
import { getLatestLesson, getLatestQuiz, getCurrentProject, getMastery } from "@/lib/queries";

export const revalidate = 300;

export default async function TodayPage() {
  const [lesson, quiz, project, mastery] = await Promise.all([
    getLatestLesson(),
    getLatestQuiz(),
    getCurrentProject(),
    getMastery(),
  ]);

  const avg =
    mastery.length > 0 ? Math.round(mastery.reduce((s, m) => s + m.score, 0) / mastery.length) : 0;

  return (
    <div className="space-y-7">
      <PageHeader
        title="Today"
        subtitle="Your 30-minute AI Engineering session."
        right={<MasteryRing value={avg} />}
      />

      <div
        className="flex items-center gap-3.5 rounded-xl2 border border-edge px-[18px] py-3.5"
        style={{ background: "linear-gradient(90deg,var(--teal-soft),var(--indigo-soft))" }}
      >
        <Mascot size={40} className="flex-none" />
        <div>
          <div className="text-[15px] font-extrabold text-head">Your sensei is ready.</div>
          <div className="mt-0.5 text-[13.5px] text-muted">
            A focused lesson, a quick quiz, and this week&apos;s project — all in one place.
          </div>
        </div>
      </div>

      {!isConfigured() && (
        <EmptyState
          title="Supabase isn't connected yet."
          hint="Set NEXT_PUBLIC_SUPABASE_URL and NEXT_PUBLIC_SUPABASE_ANON_KEY, then run schema.sql + seed.sql."
        />
      )}

      <section>
        <SectionTitle>Today&apos;s lesson</SectionTitle>
        {lesson ? (
          <Card>
            <div className="mb-2 flex items-center gap-2">
              <Badge tone="indigo">{lesson.format}</Badge>
              <span className="text-xs text-faint">{lesson.lesson_date}</span>
            </div>
            <h2 className="mb-2 font-display text-2xl font-semibold text-head">{lesson.title}</h2>
            <div className="prose-sensei line-clamp-6 whitespace-pre-wrap text-sm text-muted">
              {lesson.content}
            </div>
          </Card>
        ) : (
          <EmptyState title="No lesson yet." hint="The sensei-lesson routine posts the first one tomorrow morning." />
        )}
      </section>

      <div className="grid gap-5 md:grid-cols-2">
        <section>
          <SectionTitle>Today&apos;s quiz</SectionTitle>
          {quiz ? (
            <Card>
              <span className="text-xs text-faint">{quiz.quiz_date}</span>
              <p className="mt-2 text-sm text-muted">
                {Array.isArray(quiz.questions) ? quiz.questions.length : 0} questions waiting in{" "}
                <span className="text-head">#sensei</span> — answer there.
              </p>
            </Card>
          ) : (
            <EmptyState title="No quiz yet." />
          )}
        </section>

        <section>
          <SectionTitle>This week&apos;s project</SectionTitle>
          {project ? (
            <Card>
              <div className="mb-2 flex items-center gap-2">
                <Badge tone="teal">Week {project.week}</Badge>
                <Badge>{project.status}</Badge>
              </div>
              <h3 className="font-display text-lg font-semibold text-head">{project.title}</h3>
            </Card>
          ) : (
            <EmptyState title="No active project." />
          )}
        </section>
      </div>
    </div>
  );
}

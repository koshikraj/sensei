import { Card, SectionTitle, Badge, EmptyState } from "@/components/ui";
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
    mastery.length > 0
      ? Math.round(mastery.reduce((s, m) => s + m.score, 0) / mastery.length)
      : 0;

  return (
    <div className="space-y-8">
      <div className="flex items-end justify-between">
        <div>
          <h1 className="text-2xl font-semibold text-white">Today</h1>
          <p className="text-muted text-sm mt-1">Your 30-minute AI Engineering session.</p>
        </div>
        <div className="text-right">
          <div className="text-3xl font-semibold text-white">{avg}%</div>
          <div className="text-xs text-muted">avg mastery</div>
        </div>
      </div>

      {!isConfigured() && (
        <EmptyState
          title="Supabase isn't connected yet."
          hint="Set NEXT_PUBLIC_SUPABASE_URL and NEXT_PUBLIC_SUPABASE_ANON_KEY, then run schema.sql + seed.sql."
        />
      )}

      <section>
        <SectionTitle>Today's lesson</SectionTitle>
        {lesson ? (
          <Card>
            <div className="flex items-center gap-2 mb-2">
              <Badge>{lesson.format}</Badge>
              <span className="text-xs text-muted">{lesson.lesson_date}</span>
            </div>
            <h3 className="text-lg font-medium text-white mb-2">{lesson.title}</h3>
            <div className="prose-sensei text-sm text-gray-300 line-clamp-6 whitespace-pre-wrap">
              {lesson.content}
            </div>
          </Card>
        ) : (
          <EmptyState title="No lesson yet." hint="The sensei-lesson routine posts the first one tomorrow morning." />
        )}
      </section>

      <div className="grid gap-6 md:grid-cols-2">
        <section>
          <SectionTitle>Today's quiz</SectionTitle>
          {quiz ? (
            <Card>
              <span className="text-xs text-muted">{quiz.quiz_date}</span>
              <p className="mt-2 text-sm text-gray-300">
                {Array.isArray(quiz.questions) ? quiz.questions.length : 0} questions waiting in
                <span className="text-white"> #sensei</span> — answer there.
              </p>
            </Card>
          ) : (
            <EmptyState title="No quiz yet." />
          )}
        </section>

        <section>
          <SectionTitle>This week's project</SectionTitle>
          {project ? (
            <Card>
              <div className="flex items-center gap-2 mb-2">
                <Badge>Week {project.week}</Badge>
                <Badge>{project.status}</Badge>
              </div>
              <h3 className="text-white font-medium">{project.title}</h3>
            </Card>
          ) : (
            <EmptyState title="No active project." />
          )}
        </section>
      </div>
    </div>
  );
}

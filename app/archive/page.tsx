import { Card, SectionTitle, Badge, EmptyState, PageHeader } from "@/components/ui";
import { getLessons, getProjects } from "@/lib/queries";

export const revalidate = 300;

export default async function ArchivePage() {
  const [lessons, projects] = await Promise.all([getLessons(100), getProjects()]);

  return (
    <div className="space-y-8">
      <PageHeader title="Archive" subtitle="Everything Sensei has taught so far." />

      <section>
        <SectionTitle>Past lessons</SectionTitle>
        {lessons.length === 0 ? (
          <EmptyState title="No lessons yet." />
        ) : (
          <Card className="divide-y divide-edge p-0">
            {lessons.map((l) => (
              <div key={l.id} className="flex items-center gap-3 px-4 py-3">
                <span className="w-24 text-xs text-faint">{l.lesson_date}</span>
                <span className="text-body">{l.title}</span>
                <span className="ml-auto">
                  <Badge>{l.format}</Badge>
                </span>
              </div>
            ))}
          </Card>
        )}
      </section>

      <section>
        <SectionTitle>Weekly projects</SectionTitle>
        {projects.length === 0 ? (
          <EmptyState title="No projects yet." />
        ) : (
          <div className="grid gap-4 md:grid-cols-2">
            {projects.map((p) => (
              <Card key={p.id}>
                <Badge tone="indigo">Week {p.week}</Badge>
                <h3 className="mt-2 font-display text-lg font-semibold text-head">{p.title}</h3>
                <div className="mt-3.5 flex items-center gap-2">
                  <span className="h-[7px] w-[7px] flex-none rounded-full bg-teal" />
                  <span className="text-[13px] font-semibold text-muted">{p.status}</span>
                </div>
              </Card>
            ))}
          </div>
        )}
      </section>
    </div>
  );
}

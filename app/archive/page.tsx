import { Card, SectionTitle, Badge, EmptyState } from "@/components/ui";
import { getLessons, getProjects } from "@/lib/queries";

export const revalidate = 300;

export default async function ArchivePage() {
  const [lessons, projects] = await Promise.all([getLessons(100), getProjects()]);

  return (
    <div className="space-y-8">
      <div>
        <h1 className="text-2xl font-semibold text-white">Archive</h1>
        <p className="text-muted text-sm mt-1">Everything Sensei has taught so far.</p>
      </div>

      <section>
        <SectionTitle>Past lessons</SectionTitle>
        {lessons.length === 0 ? (
          <EmptyState title="No lessons yet." />
        ) : (
          <Card className="p-0 divide-y divide-edge">
            {lessons.map((l) => (
              <div key={l.id} className="flex items-center gap-3 px-4 py-3">
                <span className="text-xs text-muted w-24">{l.lesson_date}</span>
                <span className="text-gray-300">{l.title}</span>
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
          <Card className="p-0 divide-y divide-edge">
            {projects.map((p) => (
              <div key={p.id} className="flex items-center gap-3 px-4 py-3">
                <Badge>Week {p.week}</Badge>
                <span className="text-gray-300">{p.title}</span>
                <span className="ml-auto">
                  <Badge>{p.status}</Badge>
                </span>
              </div>
            ))}
          </Card>
        )}
      </section>
    </div>
  );
}

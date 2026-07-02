import { Card, SectionTitle, Badge, EmptyState, PageHeader } from "@/components/ui";
import { getProgress, getProjects } from "@/lib/queries";

export const revalidate = 300;

export default async function ArchivePage() {
  const [topics, projects] = await Promise.all([getProgress(), getProjects()]);
  const done = topics.filter((t) => t.status === "done");

  return (
    <div className="space-y-8">
      <PageHeader title="Archive" subtitle="Completed topics and your module projects." />

      <section>
        <SectionTitle>Completed topics</SectionTitle>
        {done.length === 0 ? (
          <EmptyState title="No topics completed yet." />
        ) : (
          <Card className="divide-y divide-edge p-0">
            {done.map((t, i) => (
              <div key={i} className="flex items-center gap-3 px-4 py-3">
                <span className="flex-none text-teal">✓</span>
                <span className="min-w-0 flex-1 truncate text-head">{t.title}</span>
                <span className="flex-none text-xs text-faint">{t.module}</span>
                <span className="ml-auto flex-none">
                  <Badge tone="teal">{t.mastery}%</Badge>
                </span>
              </div>
            ))}
          </Card>
        )}
      </section>

      <section>
        <SectionTitle>Module projects</SectionTitle>
        {projects.length === 0 ? (
          <EmptyState title="No projects yet." />
        ) : (
          <div className="grid gap-4 md:grid-cols-2">
            {projects.map((p, i) => (
              <Card key={i}>
                <Badge tone="indigo">Module {p.moduleSeq} · {p.module}</Badge>
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

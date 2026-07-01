import { Card, Badge, EmptyState, PageHeader } from "@/components/ui";
import { getNews } from "@/lib/queries";

export const revalidate = 300;

export default async function NewsPage() {
  const news = await getNews(30);

  return (
    <div className="space-y-6">
      <PageHeader title="News" subtitle="Curated updates relevant to your current module." />

      {news.length === 0 ? (
        <EmptyState title="No news yet." hint="The sensei-news routine posts a digest a few times a week." />
      ) : (
        <div className="space-y-3.5">
          {news.map((n) => (
            <Card key={n.id}>
              <div className="mb-2 flex items-center gap-2.5">
                {n.source && <Badge tone="indigo">{n.source}</Badge>}
                <span className="text-xs text-faint">{n.news_date}</span>
              </div>
              <a
                href={n.url}
                target="_blank"
                rel="noreferrer"
                className="font-display text-lg font-semibold text-head hover:text-teal"
              >
                {n.title}
              </a>
              {n.summary && <p className="mt-2 text-sm leading-relaxed text-muted">{n.summary}</p>}
              {n.module && (
                <div className="mt-3.5">
                  <Badge tone="teal">{n.module}</Badge>
                </div>
              )}
            </Card>
          ))}
        </div>
      )}
    </div>
  );
}

import { Card, Badge, EmptyState } from "@/components/ui";
import { getNews } from "@/lib/queries";

export const revalidate = 300;

export default async function NewsPage() {
  const news = await getNews(30);

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-semibold text-white">News</h1>
        <p className="text-muted text-sm mt-1">Curated updates relevant to your current module.</p>
      </div>

      {news.length === 0 ? (
        <EmptyState title="No news yet." hint="The sensei-news routine posts a digest a few times a week." />
      ) : (
        <div className="space-y-3">
          {news.map((n) => (
            <Card key={n.id}>
              <div className="flex items-center gap-2 mb-1">
                {n.module && <Badge>{n.module}</Badge>}
                <span className="text-xs text-muted">{n.news_date}</span>
              </div>
              <a
                href={n.url}
                target="_blank"
                rel="noreferrer"
                className="text-white font-medium hover:text-accent"
              >
                {n.title}
              </a>
              {n.summary && <p className="mt-1 text-sm text-gray-300">{n.summary}</p>}
              {n.source && <p className="mt-1 text-xs text-muted">{n.source}</p>}
            </Card>
          ))}
        </div>
      )}
    </div>
  );
}

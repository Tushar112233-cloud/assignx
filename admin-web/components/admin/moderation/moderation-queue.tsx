"use client";

import { useRouter, useSearchParams, usePathname } from "next/navigation";
import { useCallback } from "react";
import { Tabs, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Button } from "@/components/ui/button";
import { ContentReviewCard } from "./content-review-card";

type FlaggedItem = {
  id: string;
  content: string;
  content_type: string;
  is_flagged: boolean;
  created_at: string;
  author_id?: string;
  seller_id?: string;
  profiles?: { full_name: string; email: string } | null;
};

export function ModerationQueue({
  data,
  total,
  page,
  totalPages,
}: {
  data: FlaggedItem[];
  total: number;
  page: number;
  totalPages: number;
}) {
  const router = useRouter();
  const searchParams = useSearchParams();
  const pathname = usePathname();

  const updateParams = useCallback(
    (key: string, value: string | null) => {
      const params = new URLSearchParams(searchParams.toString());
      if (value && value !== "all") {
        params.set(key, value);
      } else {
        params.delete(key);
      }
      if (key !== "page") params.delete("page");
      router.push(`${pathname}?${params.toString()}`);
    },
    [router, pathname, searchParams]
  );

  return (
    <div className="flex flex-col gap-4 px-4 lg:px-6">
      <div className="flex items-center justify-between">
        <Tabs
          value={searchParams.get("type") || "all"}
          onValueChange={(v) => updateParams("type", v)}
        >
          <TabsList>
            <TabsTrigger value="all">All</TabsTrigger>
            <TabsTrigger value="campus_posts">Campus Posts</TabsTrigger>
            <TabsTrigger value="listings">Listings</TabsTrigger>
          </TabsList>
        </Tabs>
        <span className="text-sm text-muted-foreground">
          {total} flagged item{total !== 1 ? "s" : ""}
        </span>
      </div>

      {data.length === 0 ? (
        <div className="flex h-40 items-center justify-center rounded-md border">
          <p className="text-muted-foreground">No flagged content found.</p>
        </div>
      ) : (
        <div className="flex flex-col gap-3">
          {data.map((item) => (
            <ContentReviewCard
              key={`${item.content_type}-${item.id}`}
              item={item}
            />
          ))}
        </div>
      )}

      <div className="flex items-center justify-between">
        <p className="text-sm text-muted-foreground">
          Page {page} of {totalPages}
        </p>
        <div className="flex gap-2">
          <Button
            variant="outline"
            size="sm"
            disabled={page <= 1}
            onClick={() => updateParams("page", String(page - 1))}
          >
            Previous
          </Button>
          <Button
            variant="outline"
            size="sm"
            disabled={page >= totalPages}
            onClick={() => updateParams("page", String(page + 1))}
          >
            Next
          </Button>
        </div>
      </div>
    </div>
  );
}

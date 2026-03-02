import { Skeleton } from "@/components/ui/skeleton";
import { Card, CardContent } from "@/components/ui/card";

export default function ContentLoading() {
  return (
    <div className="flex flex-col gap-4 py-4">
      <div className="px-4 lg:px-6">
        <Skeleton className="h-8 w-44" />
        <Skeleton className="h-4 w-64 mt-2" />
      </div>
      <div className="px-4 lg:px-6 space-y-6">
        <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-5 gap-3">
          {Array.from({ length: 5 }).map((_, i) => (
            <Card key={i}>
              <CardContent className="pt-4 pb-3 px-4">
                <Skeleton className="h-4 w-16 mb-2" />
                <Skeleton className="h-6 w-10" />
              </CardContent>
            </Card>
          ))}
        </div>
        <div>
          <Skeleton className="h-10 w-96 mb-4" />
          <div className="space-y-3">
            {Array.from({ length: 6 }).map((_, i) => (
              <Skeleton key={i} className="h-12 w-full" />
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}

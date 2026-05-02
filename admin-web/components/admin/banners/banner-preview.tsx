"use client";

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";

export function BannerPreview({
  title,
  subtitle,
  imageUrl,
  ctaText,
}: {
  title: string;
  subtitle: string;
  imageUrl: string;
  ctaText: string;
}) {
  return (
    <Card>
      <CardHeader>
        <CardTitle className="text-sm">Live Preview</CardTitle>
      </CardHeader>
      <CardContent>
        <div className="overflow-hidden rounded-lg border">
          {imageUrl ? (
            <div className="relative">
              <img
                src={imageUrl}
                alt="Banner preview"
                className="aspect-[21/9] w-full object-cover"
                onError={(e) => {
                  (e.target as HTMLImageElement).style.display = "none";
                }}
              />
              <div className="absolute inset-0 flex flex-col items-start justify-end bg-gradient-to-t from-black/60 to-transparent p-4">
                <h3 className="text-lg font-bold text-white">
                  {title || "Banner Title"}
                </h3>
                {subtitle && (
                  <p className="mt-1 text-sm text-white/80">{subtitle}</p>
                )}
                {ctaText && (
                  <Button size="sm" className="mt-2" variant="secondary">
                    {ctaText}
                  </Button>
                )}
              </div>
            </div>
          ) : (
            <div className="flex aspect-[21/9] flex-col items-center justify-center bg-muted p-4 text-center">
              <h3 className="text-lg font-bold">
                {title || "Banner Title"}
              </h3>
              {subtitle && (
                <p className="mt-1 text-sm text-muted-foreground">
                  {subtitle}
                </p>
              )}
              {ctaText && (
                <Button size="sm" className="mt-3" variant="outline">
                  {ctaText}
                </Button>
              )}
              {!title && !subtitle && (
                <p className="text-sm text-muted-foreground">
                  Add content to see preview
                </p>
              )}
            </div>
          )}
        </div>
      </CardContent>
    </Card>
  );
}

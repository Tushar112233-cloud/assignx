"use client";

import { useState } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Label } from "@/components/ui/label";
import { Checkbox } from "@/components/ui/checkbox";
import {
  Select,
  SelectTrigger,
  SelectValue,
  SelectContent,
  SelectItem,
} from "@/components/ui/select";
import {
  Card,
  CardContent,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import {
  createLearningResource,
  updateLearningResource,
} from "@/lib/admin/actions/learning";
import { toast } from "sonner";
import type { LearningResource } from "@/lib/admin/types";

const AUDIENCE_OPTIONS = ["student", "professional", "business", "supervisor", "doer"];

export function LearningForm({
  resource,
}: {
  resource?: LearningResource;
}) {
  const router = useRouter();
  const searchParams = useSearchParams();
  const editId = resource?.id || searchParams.get("edit");
  const isEdit = !!editId;

  const [loading, setLoading] = useState(false);
  const [title, setTitle] = useState(resource?.title || "");
  const [description, setDescription] = useState(resource?.description || "");
  const [contentType, setContentType] = useState(resource?.content_type || "article");
  const [contentUrl, setContentUrl] = useState(resource?.content_url || "");
  const [thumbnailUrl, setThumbnailUrl] = useState(resource?.thumbnail_url || "");
  const [category, setCategory] = useState(resource?.category || "");
  const [tagsInput, setTagsInput] = useState((resource?.tags || []).join(", "));
  const [targetAudience, setTargetAudience] = useState<string[]>(
    resource?.target_audience || []
  );
  const [isActive, setIsActive] = useState(resource?.is_active ?? true);
  const [isFeatured, setIsFeatured] = useState(resource?.is_featured ?? false);

  const toggleAudience = (value: string) => {
    setTargetAudience((prev) =>
      prev.includes(value) ? prev.filter((v) => v !== value) : [...prev, value]
    );
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!title.trim()) {
      toast.error("Title is required");
      return;
    }

    setLoading(true);
    try {
      const tags = tagsInput
        .split(",")
        .map((t) => t.trim())
        .filter(Boolean);

      const formData = {
        title: title.trim(),
        description: description.trim() || undefined,
        content_type: contentType,
        content_url: contentUrl.trim() || undefined,
        thumbnail_url: thumbnailUrl.trim() || undefined,
        category: category.trim() || undefined,
        tags,
        target_audience: targetAudience,
        is_active: isActive,
        is_featured: isFeatured,
      };

      if (isEdit && editId) {
        await updateLearningResource(editId, formData);
        toast.success("Resource updated successfully");
      } else {
        await createLearningResource(formData);
        toast.success("Resource created successfully");
      }
      router.push("/admin/learning");
      router.refresh();
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Failed to save");
    } finally {
      setLoading(false);
    }
  };

  return (
    <Card>
      <CardHeader>
        <CardTitle>{isEdit ? "Edit Resource" : "New Resource"}</CardTitle>
      </CardHeader>
      <CardContent>
        <form onSubmit={handleSubmit} className="flex flex-col gap-6">
          <div className="grid gap-4 sm:grid-cols-2">
            <div className="flex flex-col gap-2">
              <Label htmlFor="title">Title</Label>
              <Input
                id="title"
                value={title}
                onChange={(e) => setTitle(e.target.value)}
                placeholder="Resource title"
                required
              />
            </div>
            <div className="flex flex-col gap-2">
              <Label htmlFor="content_type">Content Type</Label>
              <Select value={contentType} onValueChange={setContentType}>
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="article">Article</SelectItem>
                  <SelectItem value="video">Video</SelectItem>
                  <SelectItem value="pdf">PDF</SelectItem>
                  <SelectItem value="link">Link</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </div>

          <div className="flex flex-col gap-2">
            <Label htmlFor="description">Description</Label>
            <Textarea
              id="description"
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              placeholder="Brief description of the resource"
              rows={3}
            />
          </div>

          <div className="grid gap-4 sm:grid-cols-2">
            <div className="flex flex-col gap-2">
              <Label htmlFor="content_url">Content URL</Label>
              <Input
                id="content_url"
                value={contentUrl}
                onChange={(e) => setContentUrl(e.target.value)}
                placeholder="https://..."
              />
            </div>
            <div className="flex flex-col gap-2">
              <Label htmlFor="thumbnail_url">Thumbnail URL</Label>
              <Input
                id="thumbnail_url"
                value={thumbnailUrl}
                onChange={(e) => setThumbnailUrl(e.target.value)}
                placeholder="https://..."
              />
            </div>
          </div>

          <div className="grid gap-4 sm:grid-cols-2">
            <div className="flex flex-col gap-2">
              <Label htmlFor="category">Category</Label>
              <Input
                id="category"
                value={category}
                onChange={(e) => setCategory(e.target.value)}
                placeholder="e.g. Programming, Design"
              />
            </div>
            <div className="flex flex-col gap-2">
              <Label htmlFor="tags">Tags (comma separated)</Label>
              <Input
                id="tags"
                value={tagsInput}
                onChange={(e) => setTagsInput(e.target.value)}
                placeholder="react, javascript, web"
              />
            </div>
          </div>

          <div className="flex flex-col gap-2">
            <Label>Target Audience</Label>
            <div className="flex flex-wrap gap-4">
              {AUDIENCE_OPTIONS.map((option) => (
                <label key={option} className="flex items-center gap-2 text-sm">
                  <Checkbox
                    checked={targetAudience.includes(option)}
                    onCheckedChange={() => toggleAudience(option)}
                  />
                  <span className="capitalize">{option}</span>
                </label>
              ))}
            </div>
          </div>

          <div className="flex flex-wrap gap-6">
            <label className="flex items-center gap-2 text-sm">
              <Checkbox
                checked={isActive}
                onCheckedChange={(checked) => setIsActive(!!checked)}
              />
              Active
            </label>
            <label className="flex items-center gap-2 text-sm">
              <Checkbox
                checked={isFeatured}
                onCheckedChange={(checked) => setIsFeatured(!!checked)}
              />
              Featured
            </label>
          </div>

          <div className="flex gap-3">
            <Button type="submit" disabled={loading}>
              {loading
                ? "Saving..."
                : isEdit
                  ? "Update Resource"
                  : "Create Resource"}
            </Button>
            <Button
              type="button"
              variant="outline"
              onClick={() => router.push("/admin/learning")}
            >
              Cancel
            </Button>
          </div>
        </form>
      </CardContent>
    </Card>
  );
}

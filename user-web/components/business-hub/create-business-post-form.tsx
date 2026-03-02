"use client";

/**
 * CreateBusinessPostForm - Form for creating a new Business Hub post
 * Includes title, content, category, tags, company name, and industry
 */

import { useState, useCallback } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { motion, AnimatePresence } from "framer-motion";
import { ArrowLeft, Loader2, X, Plus, Check } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Label } from "@/components/ui/label";
import { Badge } from "@/components/ui/badge";
import { cn } from "@/lib/utils";
import { toast } from "sonner";
import { createBusinessHubPost } from "@/lib/actions/business-hub";
import { BUSINESS_HUB_CATEGORIES } from "@/types/business-hub";

/**
 * Categories for selection (excluding "all")
 */
const selectableCategories = BUSINESS_HUB_CATEGORIES.filter(
  (c) => c.id !== "all"
);

/**
 * Industry options for the select dropdown
 */
const INDUSTRIES = [
  "Technology",
  "Finance",
  "Healthcare",
  "Education",
  "E-Commerce",
  "Real Estate",
  "Manufacturing",
  "Consulting",
  "Media",
  "Agriculture",
  "Energy",
  "Transportation",
  "Food & Beverage",
  "Entertainment",
  "Other",
];

export function CreateBusinessPostForm() {
  const router = useRouter();

  // Form state
  const [title, setTitle] = useState("");
  const [content, setContent] = useState("");
  const [selectedCategory, setSelectedCategory] = useState<string | null>(null);
  const [companyName, setCompanyName] = useState("");
  const [industry, setIndustry] = useState("");
  const [tags, setTags] = useState<string[]>([]);
  const [tagInput, setTagInput] = useState("");
  const [isSubmitting, setIsSubmitting] = useState(false);

  /**
   * Add a tag from the input field
   */
  const handleAddTag = useCallback(() => {
    const tag = tagInput.trim().toLowerCase();
    if (tag && !tags.includes(tag) && tags.length < 5) {
      setTags((prev) => [...prev, tag]);
      setTagInput("");
    }
  }, [tagInput, tags]);

  /**
   * Handle Enter key in tag input
   */
  const handleTagKeyDown = useCallback(
    (e: React.KeyboardEvent) => {
      if (e.key === "Enter") {
        e.preventDefault();
        handleAddTag();
      }
    },
    [handleAddTag]
  );

  /**
   * Remove a tag by index
   */
  const handleRemoveTag = useCallback((index: number) => {
    setTags((prev) => prev.filter((_, i) => i !== index));
  }, []);

  /**
   * Submit the form
   */
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!selectedCategory) {
      toast.error("Please select a category");
      return;
    }
    if (!title.trim()) {
      toast.error("Please enter a title");
      return;
    }
    if (!content.trim()) {
      toast.error("Please enter content");
      return;
    }

    setIsSubmitting(true);

    try {
      const { data, error } = await createBusinessHubPost({
        title: title.trim(),
        content: content.trim(),
        category: selectedCategory,
        tags,
        companyName: companyName.trim() || undefined,
        industry: industry || undefined,
      });

      if (error) {
        toast.error(error);
        return;
      }

      toast.success("Post created successfully!");
      router.push(`/business-hub/${data?.id}`);
    } catch (err) {
      const message =
        err instanceof Error ? err.message : "Failed to create post";
      toast.error(message);
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="min-h-[calc(100vh-3.5rem)] bg-background">
      {/* Header */}
      <div className="sticky top-14 z-20 bg-background/80 backdrop-blur-lg border-b border-border/50">
        <div className="max-w-3xl mx-auto px-4 py-4 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <Button variant="ghost" size="icon" asChild>
              <Link href="/business-hub">
                <ArrowLeft className="h-5 w-5" />
              </Link>
            </Button>
            <h1 className="font-semibold">Create Post</h1>
          </div>
          <Button
            onClick={handleSubmit}
            disabled={
              isSubmitting ||
              !selectedCategory ||
              !title.trim() ||
              !content.trim()
            }
          >
            {isSubmitting ? (
              <>
                <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                Posting...
              </>
            ) : (
              "Post"
            )}
          </Button>
        </div>
      </div>

      {/* Form */}
      <div className="max-w-3xl mx-auto px-4 py-6">
        <form onSubmit={handleSubmit} className="space-y-8">
          {/* Category Selection */}
          <div className="space-y-3">
            <Label className="text-base font-medium">Category</Label>
            <div className="grid grid-cols-2 sm:grid-cols-3 gap-3">
              {selectableCategories.map((cat) => {
                const isSelected = selectedCategory === cat.id;

                return (
                  <motion.button
                    key={cat.id}
                    type="button"
                    onClick={() => setSelectedCategory(cat.id)}
                    whileTap={{ scale: 0.98 }}
                    className={cn(
                      "relative p-4 rounded-xl border-2 text-left transition-all",
                      isSelected
                        ? "border-primary bg-primary/5"
                        : "border-border hover:border-border/80 hover:bg-muted/50"
                    )}
                  >
                    {isSelected && (
                      <div className="absolute top-2 right-2">
                        <Check className="h-4 w-4 text-primary" />
                      </div>
                    )}
                    <Badge
                      className={cn(
                        "mb-1",
                        cat.lightBg,
                        cat.darkBg,
                        cat.textColor
                      )}
                    >
                      {cat.label}
                    </Badge>
                  </motion.button>
                );
              })}
            </div>
          </div>

          {/* Title */}
          <div className="space-y-2">
            <Label htmlFor="title" className="text-base font-medium">
              Title
            </Label>
            <Input
              id="title"
              placeholder="Enter a descriptive title..."
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              maxLength={200}
              className="text-lg h-12"
            />
            <p className="text-xs text-muted-foreground text-right">
              {title.length}/200
            </p>
          </div>

          {/* Content */}
          <div className="space-y-2">
            <Label htmlFor="content" className="text-base font-medium">
              Content
            </Label>
            <Textarea
              id="content"
              placeholder="Share your business insights, pitch an idea, or discuss strategies..."
              value={content}
              onChange={(e) => setContent(e.target.value)}
              className="min-h-[200px] text-base leading-relaxed resize-none"
            />
          </div>

          {/* Company Name */}
          <div className="space-y-2">
            <Label htmlFor="companyName" className="text-base font-medium">
              Company Name (Optional)
            </Label>
            <Input
              id="companyName"
              placeholder="Your company or startup name"
              value={companyName}
              onChange={(e) => setCompanyName(e.target.value)}
              maxLength={100}
            />
          </div>

          {/* Industry */}
          <div className="space-y-2">
            <Label htmlFor="industry" className="text-base font-medium">
              Industry (Optional)
            </Label>
            <div className="grid grid-cols-3 sm:grid-cols-4 gap-2">
              {INDUSTRIES.map((ind) => (
                <button
                  key={ind}
                  type="button"
                  onClick={() => setIndustry(industry === ind ? "" : ind)}
                  className={cn(
                    "px-3 py-2 rounded-lg border text-sm transition-all",
                    industry === ind
                      ? "border-primary bg-primary/5 text-primary font-medium"
                      : "border-border hover:bg-muted/50 text-muted-foreground"
                  )}
                >
                  {ind}
                </button>
              ))}
            </div>
          </div>

          {/* Tags */}
          <div className="space-y-3">
            <Label className="text-base font-medium">
              Tags (Optional, up to 5)
            </Label>

            <div className="flex gap-2">
              <Input
                placeholder="Add a tag..."
                value={tagInput}
                onChange={(e) => setTagInput(e.target.value)}
                onKeyDown={handleTagKeyDown}
                maxLength={30}
                disabled={tags.length >= 5}
              />
              <Button
                type="button"
                variant="outline"
                size="icon"
                onClick={handleAddTag}
                disabled={!tagInput.trim() || tags.length >= 5}
              >
                <Plus className="h-4 w-4" />
              </Button>
            </div>

            <AnimatePresence>
              <div className="flex flex-wrap gap-2">
                {tags.map((tag, index) => (
                  <motion.div
                    key={tag}
                    initial={{ opacity: 0, scale: 0.8 }}
                    animate={{ opacity: 1, scale: 1 }}
                    exit={{ opacity: 0, scale: 0.8 }}
                  >
                    <Badge
                      variant="secondary"
                      className="gap-1 pr-1 cursor-pointer hover:bg-destructive/10"
                      onClick={() => handleRemoveTag(index)}
                    >
                      {tag}
                      <X className="h-3 w-3" />
                    </Badge>
                  </motion.div>
                ))}
              </div>
            </AnimatePresence>
          </div>

          {/* Mobile submit */}
          <div className="sm:hidden">
            <Button
              type="submit"
              className="w-full"
              disabled={
                isSubmitting ||
                !selectedCategory ||
                !title.trim() ||
                !content.trim()
              }
            >
              {isSubmitting ? (
                <>
                  <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                  Creating Post...
                </>
              ) : (
                "Create Post"
              )}
            </Button>
          </div>
        </form>
      </div>
    </div>
  );
}

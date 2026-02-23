"use client";

import { useState, useRef, useCallback } from "react";
import { useRouter } from "next/navigation";
import { motion, AnimatePresence } from "framer-motion";
import {
  ArrowLeft,
  ImagePlus,
  X,
  Loader2,
  HelpCircle,
  Home,
  Briefcase,
  BookOpen,
  Calendar,
  ShoppingBag,
  Search,
  Car,
  Users,
  Trophy,
  Megaphone,
  MessageSquare,
  AlertCircle,
  Check,
} from "lucide-react";
import Link from "next/link";
import Image from "next/image";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Label } from "@/components/ui/label";
import { Badge } from "@/components/ui/badge";
import { cn } from "@/lib/utils";
import { toast } from "sonner";
import { useUserStore } from "@/stores/user-store";
import {
  createCampusConnectPost,
  uploadCampusConnectImage,
  checkCollegeVerification,
} from "@/lib/actions/campus-connect";
import type { CampusConnectCategory } from "@/types/campus-connect";

/**
 * Category configuration
 * Must match database enum values exactly
 */
const categories: Array<{
  id: CampusConnectCategory;
  label: string;
  description: string;
  icon: typeof HelpCircle;
  color: string;
}> = [
  {
    id: "questions",
    label: "Questions",
    description: "Academic Q&A & doubts",
    icon: HelpCircle,
    color: "bg-blue-100 text-blue-700 dark:bg-blue-900/40 dark:text-blue-300",
  },
  {
    id: "housing",
    label: "Housing",
    description: "PG, hostel, flat listings",
    icon: Home,
    color: "bg-emerald-100 text-emerald-700 dark:bg-emerald-900/40 dark:text-emerald-300",
  },
  {
    id: "opportunities",
    label: "Opportunities",
    description: "Jobs, internships & gigs",
    icon: Briefcase,
    color: "bg-purple-100 text-purple-700 dark:bg-purple-900/40 dark:text-purple-300",
  },
  {
    id: "resources",
    label: "Resources",
    description: "Study tips & materials",
    icon: BookOpen,
    color: "bg-pink-100 text-pink-700 dark:bg-pink-900/40 dark:text-pink-300",
  },
  {
    id: "events",
    label: "Events",
    description: "Campus events & fests",
    icon: Calendar,
    color: "bg-cyan-100 text-cyan-700 dark:bg-cyan-900/40 dark:text-cyan-300",
  },
  {
    id: "marketplace",
    label: "Marketplace",
    description: "Buy & sell items",
    icon: ShoppingBag,
    color: "bg-amber-100 text-amber-700 dark:bg-amber-900/40 dark:text-amber-300",
  },
  {
    id: "lost_found",
    label: "Lost & Found",
    description: "Lost or found items",
    icon: Search,
    color: "bg-red-100 text-red-700 dark:bg-red-900/40 dark:text-red-300",
  },
  {
    id: "rides",
    label: "Rides",
    description: "Carpool & ride sharing",
    icon: Car,
    color: "bg-indigo-100 text-indigo-700 dark:bg-indigo-900/40 dark:text-indigo-300",
  },
  {
    id: "study_groups",
    label: "Study Groups",
    description: "Study groups & teams",
    icon: Users,
    color: "bg-violet-100 text-violet-700 dark:bg-violet-900/40 dark:text-violet-300",
  },
  {
    id: "clubs",
    label: "Clubs",
    description: "Club activities & societies",
    icon: Trophy,
    color: "bg-yellow-100 text-yellow-700 dark:bg-yellow-900/40 dark:text-yellow-300",
  },
  {
    id: "announcements",
    label: "Announcements",
    description: "Official announcements",
    icon: Megaphone,
    color: "bg-slate-100 text-slate-700 dark:bg-slate-900/40 dark:text-slate-300",
  },
  {
    id: "discussions",
    label: "Discussions",
    description: "General discussions",
    icon: MessageSquare,
    color: "bg-teal-100 text-teal-700 dark:bg-teal-900/40 dark:text-teal-300",
  },
];

/**
 * CreatePostForm - Form component for creating new campus connect posts
 */
export function CreatePostForm() {
  const router = useRouter();
  const { user } = useUserStore();
  const fileInputRef = useRef<HTMLInputElement>(null);

  // Form state
  const [selectedCategory, setSelectedCategory] = useState<CampusConnectCategory | null>(null);
  const [title, setTitle] = useState("");
  const [content, setContent] = useState("");
  const [images, setImages] = useState<Array<{ file: File; preview: string; uploading: boolean }>>([]);
  const [uploadedUrls, setUploadedUrls] = useState<string[]>([]);

  // UI state
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [isVerified, setIsVerified] = useState<boolean | null>(null);
  const [isCheckingVerification, setIsCheckingVerification] = useState(true);

  // Check verification on mount
  useState(() => {
    async function check() {
      const { isVerified: verified } = await checkCollegeVerification();
      setIsVerified(verified);
      setIsCheckingVerification(false);
    }
    check();
  });

  // Handle image selection
  const handleImageSelect = useCallback((e: React.ChangeEvent<HTMLInputElement>) => {
    const files = e.target.files;
    if (!files || files.length === 0) return;

    const newImages = Array.from(files).slice(0, 5 - images.length).map(file => ({
      file,
      preview: URL.createObjectURL(file),
      uploading: false,
    }));

    setImages(prev => [...prev, ...newImages]);

    // Upload images
    newImages.forEach(async (img, index) => {
      const actualIndex = images.length + index;
      setImages(prev =>
        prev.map((item, i) => (i === actualIndex ? { ...item, uploading: true } : item))
      );

      try {
        // Convert file to base64
        const reader = new FileReader();
        reader.onloadend = async () => {
          const base64Data = (reader.result as string).split(",")[1];
          const { data, error } = await uploadCampusConnectImage({
            name: img.file.name,
            type: img.file.type,
            size: img.file.size,
            base64Data,
          });

          if (error) {
            toast.error(`Failed to upload ${img.file.name}`);
            setImages(prev => prev.filter((_, i) => i !== actualIndex));
          } else if (data) {
            setUploadedUrls(prev => [...prev, data.url]);
            setImages(prev =>
              prev.map((item, i) => (i === actualIndex ? { ...item, uploading: false } : item))
            );
          }
        };
        reader.readAsDataURL(img.file);
      } catch {
        toast.error(`Failed to upload ${img.file.name}`);
        setImages(prev => prev.filter((_, i) => i !== actualIndex));
      }
    });

    // Reset input
    e.target.value = "";
  }, [images.length]);

  // Remove image
  const handleRemoveImage = (index: number) => {
    URL.revokeObjectURL(images[index].preview);
    setImages(prev => prev.filter((_, i) => i !== index));
    setUploadedUrls(prev => prev.filter((_, i) => i !== index));
  };

  // Submit form
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

    // Check if any images are still uploading
    if (images.some(img => img.uploading)) {
      toast.error("Please wait for images to finish uploading");
      return;
    }

    setIsSubmitting(true);

    try {
      const { data, error } = await createCampusConnectPost({
        category: selectedCategory,
        title: title.trim(),
        content: content.trim(),
        imageUrls: uploadedUrls,
      });

      if (error) {
        toast.error(error);
        return;
      }

      toast.success("Post created successfully!");
      router.push(`/campus-connect/${data?.id}`);
    } catch (err) {
      const message = err instanceof Error ? err.message : "Failed to create post";
      toast.error(message);
    } finally {
      setIsSubmitting(false);
    }
  };

  // Loading state
  if (isCheckingVerification) {
    return (
      <div className="min-h-[calc(100vh-3.5rem)] flex items-center justify-center">
        <Loader2 className="h-8 w-8 animate-spin text-muted-foreground" />
      </div>
    );
  }

  // Not verified state
  if (!isVerified) {
    return (
      <div className="min-h-[calc(100vh-3.5rem)] flex items-center justify-center p-6">
        <div className="max-w-md text-center">
          <div className="h-16 w-16 rounded-2xl bg-amber-100 dark:bg-amber-900/30 flex items-center justify-center mx-auto mb-4">
            <AlertCircle className="h-8 w-8 text-amber-600 dark:text-amber-400" />
          </div>
          <h2 className="text-xl font-semibold mb-2">Verification Required</h2>
          <p className="text-muted-foreground mb-6">
            Only verified college students can create posts. Please verify your college email to continue.
          </p>
          <div className="flex gap-3 justify-center">
            <Button variant="outline" asChild>
              <Link href="/campus-connect">
                <ArrowLeft className="h-4 w-4 mr-2" />
                Go Back
              </Link>
            </Button>
            <Button asChild>
              <Link href="/settings">Verify Account</Link>
            </Button>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-[calc(100vh-3.5rem)] bg-background">
      {/* Header */}
      <div className="sticky top-14 z-20 bg-background/80 backdrop-blur-lg border-b border-border/50">
        <div className="max-w-3xl mx-auto px-4 py-4 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <Button variant="ghost" size="icon" asChild>
              <Link href="/campus-connect">
                <ArrowLeft className="h-5 w-5" />
              </Link>
            </Button>
            <h1 className="font-semibold">Create Post</h1>
          </div>
          <Button
            onClick={handleSubmit}
            disabled={isSubmitting || !selectedCategory || !title.trim() || !content.trim()}
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
              {categories.map((cat) => {
                const Icon = cat.icon;
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
                    <Badge className={cn("mb-2", cat.color)}>
                      <Icon className="h-3 w-3 mr-1" />
                      {cat.label}
                    </Badge>
                    <p className="text-xs text-muted-foreground">{cat.description}</p>
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
              placeholder="Share your thoughts, ask questions, or provide details..."
              value={content}
              onChange={(e) => setContent(e.target.value)}
              className="min-h-[200px] text-base leading-relaxed resize-none"
            />
          </div>

          {/* Images */}
          <div className="space-y-3">
            <Label className="text-base font-medium">Images (Optional)</Label>
            <div className="flex flex-wrap gap-3">
              {/* Image Previews */}
              <AnimatePresence>
                {images.map((img, index) => (
                  <motion.div
                    key={img.preview}
                    initial={{ opacity: 0, scale: 0.8 }}
                    animate={{ opacity: 1, scale: 1 }}
                    exit={{ opacity: 0, scale: 0.8 }}
                    className="relative w-24 h-24 rounded-xl overflow-hidden border border-border"
                  >
                    <Image
                      src={img.preview}
                      alt={`Upload ${index + 1}`}
                      fill
                      className="object-cover"
                    />
                    {img.uploading ? (
                      <div className="absolute inset-0 bg-background/80 flex items-center justify-center">
                        <Loader2 className="h-5 w-5 animate-spin text-primary" />
                      </div>
                    ) : (
                      <button
                        type="button"
                        onClick={() => handleRemoveImage(index)}
                        className="absolute top-1 right-1 p-1 rounded-full bg-background/80 hover:bg-background transition-colors"
                      >
                        <X className="h-3 w-3" />
                      </button>
                    )}
                  </motion.div>
                ))}
              </AnimatePresence>

              {/* Add Image Button */}
              {images.length < 5 && (
                <button
                  type="button"
                  onClick={() => fileInputRef.current?.click()}
                  className="w-24 h-24 rounded-xl border-2 border-dashed border-border hover:border-primary/50 hover:bg-muted/50 flex flex-col items-center justify-center gap-1 transition-colors"
                >
                  <ImagePlus className="h-6 w-6 text-muted-foreground" />
                  <span className="text-xs text-muted-foreground">Add</span>
                </button>
              )}
            </div>
            <p className="text-xs text-muted-foreground">
              Up to 5 images, max 5MB each (JPEG, PNG, WebP, GIF)
            </p>
            <input
              ref={fileInputRef}
              type="file"
              accept="image/jpeg,image/png,image/webp,image/gif"
              multiple
              onChange={handleImageSelect}
              className="hidden"
            />
          </div>

          {/* Submit Button (Mobile) */}
          <div className="sm:hidden">
            <Button
              type="submit"
              className="w-full"
              disabled={isSubmitting || !selectedCategory || !title.trim() || !content.trim()}
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

export default CreatePostForm;

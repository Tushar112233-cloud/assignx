"use client";

import { useState, useCallback } from "react";
import { useRouter } from "next/navigation";
import {
  ArrowLeft,
  Package,
  Home,
  Briefcase,
  MessageSquare,
  X,
  Loader2,
  Upload,
  AlertCircle,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Switch } from "@/components/ui/switch";
import { Badge } from "@/components/ui/badge";
import { Progress } from "@/components/ui/progress";
import { toast } from "sonner";
import { cn } from "@/lib/utils";
import type { ListingType, ProductCondition } from "@/types/marketplace";
import {
  uploadMarketplaceImage,
  createMarketplaceListing,
} from "@/lib/actions/marketplace";

interface UploadedImage {
  id: string;
  url: string;
  previewUrl: string;
  status: "uploading" | "complete" | "error";
  progress: number;
  error?: string;
}

const MAX_FILE_SIZE = 5 * 1024 * 1024;
const ALLOWED_IMAGE_TYPES = ["image/jpeg", "image/png", "image/webp", "image/gif"];

const listingTypes = [
  { id: "product" as ListingType, label: "Product", description: "Books, gadgets, supplies", icon: Package },
  { id: "housing" as ListingType, label: "Housing", description: "Rooms, flatmates", icon: Home },
  { id: "opportunity" as ListingType, label: "Opportunity", description: "Jobs, internships", icon: Briefcase },
  { id: "community" as ListingType, label: "Community", description: "Questions, reviews", icon: MessageSquare },
];

const productCategories = ["Books & Notes", "Electronics", "Drafting Tools", "Lab Equipment", "Furniture", "Clothing", "Cycles", "Other"];
const opportunityTypes = [
  { value: "internship", label: "Internship" },
  { value: "job", label: "Job" },
  { value: "event", label: "Event" },
  { value: "gig", label: "Gig/Freelance" },
  { value: "workshop", label: "Workshop" },
];
const communityTypes = [
  { value: "question", label: "Question" },
  { value: "review", label: "Review" },
  { value: "poll", label: "Poll" },
  { value: "discussion", label: "Discussion" },
];
const roomTypes = [
  { value: "single", label: "Single Room" },
  { value: "shared", label: "Shared Room" },
  { value: "flat", label: "Entire Flat" },
];

/**
 * Create Listing Page - Minimalist Design
 */
export default function CreateListingPage() {
  const router = useRouter();
  const [selectedType, setSelectedType] = useState<ListingType | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [images, setImages] = useState<UploadedImage[]>([]);
  const [isDragging, setIsDragging] = useState(false);
  const [uploadError, setUploadError] = useState<string | null>(null);

  // Common fields
  const [title, setTitle] = useState("");
  const [description, setDescription] = useState("");

  // Product fields
  const [price, setPrice] = useState("");
  const [condition, setCondition] = useState<ProductCondition>("good");
  const [category, setCategory] = useState("");
  const [isNegotiable, setIsNegotiable] = useState(true);

  // Housing fields
  const [monthlyRent, setMonthlyRent] = useState("");
  const [roomType, setRoomType] = useState("single");
  const [location, setLocation] = useState("");
  const [availableFrom, setAvailableFrom] = useState("");
  const [amenities, setAmenities] = useState<string[]>([]);
  const [amenityInput, setAmenityInput] = useState("");

  // Opportunity fields
  const [opportunityType, setOpportunityType] = useState("internship");
  const [company, setCompany] = useState("");
  const [oppLocation, setOppLocation] = useState("");
  const [isRemote, setIsRemote] = useState(false);
  const [deadline, setDeadline] = useState("");
  const [stipend, setStipend] = useState("");
  const [duration, setDuration] = useState("");

  // Community fields
  const [postType, setPostType] = useState("question");
  const [tags, setTags] = useState<string[]>([]);
  const [tagInput, setTagInput] = useState("");
  const [pollOptions, setPollOptions] = useState<string[]>(["", ""]);

  const validateFile = useCallback((file: File): string | null => {
    if (!ALLOWED_IMAGE_TYPES.includes(file.type)) {
      return `File type not supported: ${file.name}`;
    }
    if (file.size > MAX_FILE_SIZE) {
      return `File too large: ${file.name} (max 5MB)`;
    }
    return null;
  }, []);

  const uploadFile = useCallback(async (file: File): Promise<UploadedImage | null> => {
    const id = `${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
    const previewUrl = URL.createObjectURL(file);

    const uploadingImage: UploadedImage = {
      id,
      url: "",
      previewUrl,
      status: "uploading",
      progress: 0,
    };

    setImages((prev) => [...prev, uploadingImage]);

    const progressInterval = setInterval(() => {
      setImages((prev) =>
        prev.map((img) =>
          img.id === id && img.status === "uploading"
            ? { ...img, progress: Math.min(img.progress + 20, 80) }
            : img
        )
      );
    }, 200);

    try {
      const base64Data = await new Promise<string>((resolve, reject) => {
        const reader = new FileReader();
        reader.onloadend = () => resolve(reader.result as string);
        reader.onerror = reject;
        reader.readAsDataURL(file);
      });

      const result = await uploadMarketplaceImage({
        name: file.name,
        type: file.type,
        size: file.size,
        base64Data,
      });

      clearInterval(progressInterval);

      if (result.error) {
        setImages((prev) =>
          prev.map((img) =>
            img.id === id
              ? { ...img, status: "error", error: result.error || "Upload failed", progress: 0 }
              : img
          )
        );
        toast.error(result.error);
        return null;
      }

      const completedImage: UploadedImage = {
        id,
        url: result.data!.url,
        previewUrl,
        status: "complete",
        progress: 100,
      };

      setImages((prev) =>
        prev.map((img) => (img.id === id ? completedImage : img))
      );

      return completedImage;
    } catch {
      clearInterval(progressInterval);
      setImages((prev) =>
        prev.map((img) =>
          img.id === id
            ? { ...img, status: "error", error: "Upload failed", progress: 0 }
            : img
        )
      );
      toast.error("Failed to upload image");
      return null;
    }
  }, []);

  const processFiles = useCallback(
    async (files: FileList | null) => {
      if (!files) return;
      setUploadError(null);

      const currentImageCount = images.filter((img) => img.status !== "error").length;
      if (currentImageCount + files.length > 5) {
        setUploadError("Maximum 5 images allowed");
        toast.error("Maximum 5 images allowed");
        return;
      }

      for (const file of Array.from(files)) {
        const validationError = validateFile(file);
        if (validationError) {
          setUploadError(validationError);
          toast.error(validationError);
          return;
        }
      }

      for (const file of Array.from(files)) {
        await uploadFile(file);
      }
    },
    [images, validateFile, uploadFile]
  );

  const handleImageUpload = useCallback(
    (e: React.ChangeEvent<HTMLInputElement>) => {
      processFiles(e.target.files);
      e.target.value = "";
    },
    [processFiles]
  );

  const handleDragOver = useCallback((e: React.DragEvent) => {
    e.preventDefault();
    setIsDragging(true);
  }, []);

  const handleDragLeave = useCallback((e: React.DragEvent) => {
    e.preventDefault();
    setIsDragging(false);
  }, []);

  const handleDrop = useCallback(
    (e: React.DragEvent) => {
      e.preventDefault();
      setIsDragging(false);
      processFiles(e.dataTransfer.files);
    },
    [processFiles]
  );

  const removeImage = useCallback((imageId: string) => {
    setImages((prev) => {
      const imageToRemove = prev.find((img) => img.id === imageId);
      if (imageToRemove?.previewUrl) {
        URL.revokeObjectURL(imageToRemove.previewUrl);
      }
      return prev.filter((img) => img.id !== imageId);
    });
    setUploadError(null);
  }, []);

  const addAmenity = () => {
    if (amenityInput && !amenities.includes(amenityInput)) {
      setAmenities([...amenities, amenityInput]);
      setAmenityInput("");
    }
  };

  const addTag = () => {
    if (tagInput && !tags.includes(tagInput)) {
      setTags([...tags, tagInput]);
      setTagInput("");
    }
  };

  const updatePollOption = (index: number, value: string) => {
    const newOptions = [...pollOptions];
    newOptions[index] = value;
    setPollOptions(newOptions);
  };

  const addPollOption = () => {
    if (pollOptions.length < 6) {
      setPollOptions([...pollOptions, ""]);
    }
  };

  const validateForm = (): boolean => {
    if (!title.trim()) {
      toast.error("Please enter a title");
      return false;
    }

    if (selectedType === "product") {
      if (!price || parseFloat(price) <= 0) {
        toast.error("Please enter a valid price");
        return false;
      }
      if (!category) {
        toast.error("Please select a category");
        return false;
      }
    }

    if (selectedType === "housing") {
      if (!monthlyRent || parseFloat(monthlyRent) <= 0) {
        toast.error("Please enter a valid rent amount");
        return false;
      }
      if (!location.trim()) {
        toast.error("Please enter location");
        return false;
      }
    }

    if (selectedType === "community" && postType === "poll") {
      const validOptions = pollOptions.filter((o) => o.trim());
      if (validOptions.length < 2) {
        toast.error("Please add at least 2 poll options");
        return false;
      }
    }

    return true;
  };

  const handleSubmit = async () => {
    if (!validateForm() || !selectedType) return;

    const pendingUploads = images.filter((img) => img.status === "uploading");
    if (pendingUploads.length > 0) {
      toast.error("Please wait for all images to finish uploading");
      return;
    }

    const imageUrls = images
      .filter((img) => img.status === "complete" && img.url)
      .map((img) => img.url);

    setIsSubmitting(true);
    try {
      let metadata: Record<string, unknown> = {};
      let priceValue = 0;
      let locationValue: string | undefined;

      switch (selectedType) {
        case "product":
          priceValue = parseFloat(price) || 0;
          metadata = { condition, category, is_negotiable: isNegotiable };
          break;
        case "housing":
          priceValue = parseFloat(monthlyRent) || 0;
          locationValue = location;
          metadata = {
            room_type: roomType,
            available_from: availableFrom || undefined,
            amenities,
            is_available: true,
          };
          break;
        case "opportunity":
          locationValue = oppLocation;
          metadata = {
            opportunity_type: opportunityType,
            company: company || undefined,
            is_remote: isRemote,
            deadline: deadline || undefined,
            stipend: stipend ? parseFloat(stipend) : undefined,
            duration: duration || undefined,
          };
          break;
        case "community":
          metadata = {
            post_type: postType,
            tags,
            poll_options:
              postType === "poll"
                ? pollOptions
                    .filter((o) => o.trim())
                    .map((text, i) => ({ id: `opt-${i}`, text, votes: 0 }))
                : undefined,
          };
          break;
      }

      const result = await createMarketplaceListing({
        type: selectedType,
        title,
        description: description || undefined,
        price: priceValue,
        location: locationValue,
        imageUrls,
        metadata,
      });

      if (result.error) {
        toast.error(result.error);
        return;
      }

      toast.success("Listing created successfully!");
      router.push("/connect");
    } catch (error) {
      toast.error(error instanceof Error ? error.message : "Failed to create listing");
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="flex-1 p-6 md:p-8 max-w-xl mx-auto">
      {/* Header */}
      <div className="flex items-center gap-3 mb-8">
        <Button variant="ghost" size="icon" className="h-9 w-9" onClick={() => router.back()}>
          <ArrowLeft className="h-4 w-4" />
        </Button>
        <div>
          <h1 className="text-xl font-semibold">Create Listing</h1>
          <p className="text-sm text-muted-foreground">Share with your campus</p>
        </div>
      </div>

      {/* Type Selection */}
      {!selectedType ? (
        <div className="grid grid-cols-2 gap-3">
          {listingTypes.map((type) => {
            const Icon = type.icon;
            return (
              <button
                key={type.id}
                onClick={() => setSelectedType(type.id)}
                className="p-5 rounded-xl border border-border bg-card text-left hover:border-foreground/20 transition-colors"
              >
                <div className="h-10 w-10 rounded-lg bg-muted flex items-center justify-center mb-3">
                  <Icon className="h-5 w-5 text-muted-foreground" />
                </div>
                <p className="font-medium text-sm">{type.label}</p>
                <p className="text-xs text-muted-foreground mt-0.5">{type.description}</p>
              </button>
            );
          })}
        </div>
      ) : (
        <div className="space-y-6">
          {/* Back to type selection */}
          <button
            onClick={() => setSelectedType(null)}
            className="flex items-center gap-2 text-sm text-muted-foreground hover:text-foreground transition-colors"
          >
            <ArrowLeft className="h-3.5 w-3.5" />
            Change type
          </button>

          {/* Common Fields */}
          <div className="space-y-4 p-5 rounded-xl border border-border bg-card">
            <div>
              <Label htmlFor="title" className="text-sm">Title</Label>
              <Input
                id="title"
                value={title}
                onChange={(e) => setTitle(e.target.value)}
                placeholder="Enter listing title"
                className="mt-1.5"
              />
            </div>

            <div>
              <Label htmlFor="description" className="text-sm">Description</Label>
              <Textarea
                id="description"
                value={description}
                onChange={(e) => setDescription(e.target.value)}
                placeholder="Describe your listing"
                rows={3}
                className="mt-1.5 resize-none"
              />
            </div>

            {/* Image Upload */}
            <div>
              <Label className="text-sm">Images</Label>
              <div
                className={cn(
                  "mt-1.5 border-2 border-dashed rounded-lg p-6 text-center cursor-pointer transition-colors",
                  isDragging ? "border-primary bg-primary/5" : "border-border hover:border-foreground/20"
                )}
                onDragOver={handleDragOver}
                onDragLeave={handleDragLeave}
                onDrop={handleDrop}
                onClick={() => document.getElementById("image-input")?.click()}
              >
                <input
                  id="image-input"
                  type="file"
                  multiple
                  accept="image/*"
                  onChange={handleImageUpload}
                  className="hidden"
                />
                <Upload className="h-6 w-6 mx-auto mb-2 text-muted-foreground" />
                <p className="text-sm font-medium">Drop images or click to upload</p>
                <p className="text-xs text-muted-foreground mt-1">Max 5 images, 5MB each</p>
              </div>

              {uploadError && (
                <div className="flex gap-2 mt-2 p-3 bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-lg text-red-600 dark:text-red-400 text-sm">
                  <AlertCircle className="h-4 w-4 shrink-0 mt-0.5" />
                  <span>{uploadError}</span>
                </div>
              )}

              {images.length > 0 && (
                <div className="grid grid-cols-5 gap-2 mt-3">
                  {images.map((image) => (
                    <div key={image.id} className="relative aspect-square rounded-lg overflow-hidden bg-muted">
                      <img src={image.previewUrl} alt="Preview" className="w-full h-full object-cover" />
                      {image.status === "uploading" && (
                        <div className="absolute inset-0 bg-black/50 flex items-center justify-center">
                          <Loader2 className="h-4 w-4 animate-spin text-white" />
                        </div>
                      )}
                      {image.status === "error" && (
                        <div className="absolute inset-0 bg-red-500/50 flex items-center justify-center">
                          <AlertCircle className="h-4 w-4 text-white" />
                        </div>
                      )}
                      <button
                        onClick={() => removeImage(image.id)}
                        className="absolute top-1 right-1 p-1 bg-black/50 hover:bg-black/70 rounded-full text-white"
                      >
                        <X className="h-3 w-3" />
                      </button>
                      {image.status === "uploading" && (
                        <div className="absolute bottom-0 left-0 right-0">
                          <Progress value={image.progress} className="h-1 rounded-none" />
                        </div>
                      )}
                    </div>
                  ))}
                </div>
              )}
            </div>
          </div>

          {/* Product Fields */}
          {selectedType === "product" && (
            <div className="space-y-4 p-5 rounded-xl border border-border bg-card">
              <p className="text-sm font-medium">Product Details</p>
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <Label htmlFor="price" className="text-sm">Price</Label>
                  <Input
                    id="price"
                    type="number"
                    value={price}
                    onChange={(e) => setPrice(e.target.value)}
                    placeholder="₹0"
                    className="mt-1.5"
                  />
                </div>
                <div>
                  <Label htmlFor="condition" className="text-sm">Condition</Label>
                  <Select value={condition} onValueChange={(v) => setCondition(v as ProductCondition)}>
                    <SelectTrigger className="mt-1.5">
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="like_new">Like New</SelectItem>
                      <SelectItem value="good">Good</SelectItem>
                      <SelectItem value="fair">Fair</SelectItem>
                      <SelectItem value="poor">Poor</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
              </div>
              <div>
                <Label htmlFor="category" className="text-sm">Category</Label>
                <Select value={category} onValueChange={setCategory}>
                  <SelectTrigger className="mt-1.5">
                    <SelectValue placeholder="Select category" />
                  </SelectTrigger>
                  <SelectContent>
                    {productCategories.map((cat) => (
                      <SelectItem key={cat} value={cat}>{cat}</SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
              <div className="flex items-center justify-between p-3 bg-muted rounded-lg">
                <Label htmlFor="negotiable" className="text-sm cursor-pointer">Price Negotiable</Label>
                <Switch id="negotiable" checked={isNegotiable} onCheckedChange={setIsNegotiable} />
              </div>
            </div>
          )}

          {/* Housing Fields */}
          {selectedType === "housing" && (
            <div className="space-y-4 p-5 rounded-xl border border-border bg-card">
              <p className="text-sm font-medium">Housing Details</p>
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <Label htmlFor="rent" className="text-sm">Monthly Rent</Label>
                  <Input
                    id="rent"
                    type="number"
                    value={monthlyRent}
                    onChange={(e) => setMonthlyRent(e.target.value)}
                    placeholder="₹0"
                    className="mt-1.5"
                  />
                </div>
                <div>
                  <Label htmlFor="room-type" className="text-sm">Room Type</Label>
                  <Select value={roomType} onValueChange={setRoomType}>
                    <SelectTrigger className="mt-1.5">
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      {roomTypes.map((type) => (
                        <SelectItem key={type.value} value={type.value}>{type.label}</SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>
              </div>
              <div>
                <Label htmlFor="location" className="text-sm">Location</Label>
                <Input
                  id="location"
                  value={location}
                  onChange={(e) => setLocation(e.target.value)}
                  placeholder="Enter location"
                  className="mt-1.5"
                />
              </div>
              <div>
                <Label htmlFor="available-from" className="text-sm">Available From</Label>
                <Input
                  id="available-from"
                  type="date"
                  value={availableFrom}
                  onChange={(e) => setAvailableFrom(e.target.value)}
                  className="mt-1.5"
                />
              </div>
              <div>
                <Label className="text-sm">Amenities</Label>
                <div className="flex gap-2 mt-1.5">
                  <Input
                    value={amenityInput}
                    onChange={(e) => setAmenityInput(e.target.value)}
                    placeholder="Add amenity"
                    onKeyDown={(e) => e.key === "Enter" && (e.preventDefault(), addAmenity())}
                  />
                  <Button onClick={addAmenity} size="sm" variant="outline">Add</Button>
                </div>
                {amenities.length > 0 && (
                  <div className="flex flex-wrap gap-1.5 mt-2">
                    {amenities.map((amenity) => (
                      <Badge
                        key={amenity}
                        variant="secondary"
                        className="gap-1 cursor-pointer"
                        onClick={() => setAmenities(amenities.filter((a) => a !== amenity))}
                      >
                        {amenity}
                        <X className="h-3 w-3" />
                      </Badge>
                    ))}
                  </div>
                )}
              </div>
            </div>
          )}

          {/* Opportunity Fields */}
          {selectedType === "opportunity" && (
            <div className="space-y-4 p-5 rounded-xl border border-border bg-card">
              <p className="text-sm font-medium">Opportunity Details</p>
              <div>
                <Label htmlFor="opp-type" className="text-sm">Type</Label>
                <Select value={opportunityType} onValueChange={setOpportunityType}>
                  <SelectTrigger className="mt-1.5">
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    {opportunityTypes.map((type) => (
                      <SelectItem key={type.value} value={type.value}>{type.label}</SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
              <div>
                <Label htmlFor="company" className="text-sm">Company/Organization</Label>
                <Input
                  id="company"
                  value={company}
                  onChange={(e) => setCompany(e.target.value)}
                  placeholder="Enter company name"
                  className="mt-1.5"
                />
              </div>
              <div>
                <Label htmlFor="opp-location" className="text-sm">Location</Label>
                <Input
                  id="opp-location"
                  value={oppLocation}
                  onChange={(e) => setOppLocation(e.target.value)}
                  placeholder="Enter location"
                  className="mt-1.5"
                />
              </div>
              <div className="flex items-center justify-between p-3 bg-muted rounded-lg">
                <Label htmlFor="remote" className="text-sm cursor-pointer">Remote</Label>
                <Switch id="remote" checked={isRemote} onCheckedChange={setIsRemote} />
              </div>
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <Label htmlFor="deadline" className="text-sm">Deadline</Label>
                  <Input
                    id="deadline"
                    type="date"
                    value={deadline}
                    onChange={(e) => setDeadline(e.target.value)}
                    className="mt-1.5"
                  />
                </div>
                <div>
                  <Label htmlFor="stipend" className="text-sm">Stipend</Label>
                  <Input
                    id="stipend"
                    type="number"
                    value={stipend}
                    onChange={(e) => setStipend(e.target.value)}
                    placeholder="₹0"
                    className="mt-1.5"
                  />
                </div>
              </div>
              <div>
                <Label htmlFor="duration" className="text-sm">Duration</Label>
                <Input
                  id="duration"
                  value={duration}
                  onChange={(e) => setDuration(e.target.value)}
                  placeholder="e.g., 2 months"
                  className="mt-1.5"
                />
              </div>
            </div>
          )}

          {/* Community Fields */}
          {selectedType === "community" && (
            <div className="space-y-4 p-5 rounded-xl border border-border bg-card">
              <p className="text-sm font-medium">Post Details</p>
              <div>
                <Label htmlFor="post-type" className="text-sm">Post Type</Label>
                <Select value={postType} onValueChange={setPostType}>
                  <SelectTrigger className="mt-1.5">
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    {communityTypes.map((type) => (
                      <SelectItem key={type.value} value={type.value}>{type.label}</SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>

              {postType !== "poll" && (
                <div>
                  <Label className="text-sm">Tags</Label>
                  <div className="flex gap-2 mt-1.5">
                    <Input
                      value={tagInput}
                      onChange={(e) => setTagInput(e.target.value)}
                      placeholder="Add tag"
                      onKeyDown={(e) => e.key === "Enter" && (e.preventDefault(), addTag())}
                    />
                    <Button onClick={addTag} size="sm" variant="outline">Add</Button>
                  </div>
                  {tags.length > 0 && (
                    <div className="flex flex-wrap gap-1.5 mt-2">
                      {tags.map((tag) => (
                        <Badge
                          key={tag}
                          variant="secondary"
                          className="gap-1 cursor-pointer"
                          onClick={() => setTags(tags.filter((t) => t !== tag))}
                        >
                          {tag}
                          <X className="h-3 w-3" />
                        </Badge>
                      ))}
                    </div>
                  )}
                </div>
              )}

              {postType === "poll" && (
                <div>
                  <Label className="text-sm">Poll Options</Label>
                  <div className="space-y-2 mt-1.5">
                    {pollOptions.map((option, index) => (
                      <Input
                        key={index}
                        value={option}
                        onChange={(e) => updatePollOption(index, e.target.value)}
                        placeholder={`Option ${index + 1}`}
                      />
                    ))}
                    {pollOptions.length < 6 && (
                      <Button onClick={addPollOption} variant="outline" className="w-full" size="sm">
                        Add Option
                      </Button>
                    )}
                  </div>
                </div>
              )}
            </div>
          )}

          {/* Submit Button */}
          <Button onClick={handleSubmit} disabled={isSubmitting} className="w-full">
            {isSubmitting ? (
              <>
                <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                Creating...
              </>
            ) : (
              "Create Listing"
            )}
          </Button>
        </div>
      )}
    </div>
  );
}

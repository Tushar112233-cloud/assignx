"use client"

import { useState } from "react"
import { useRouter } from "next/navigation"
import { useForm } from "react-hook-form"
import { zodResolver } from "@hookform/resolvers/zod"
import { z } from "zod"
import {
  ImagePlus,
  X,
  Loader2,
  Package,
  Home,
  Briefcase,
  MessageSquare,
} from "lucide-react"
import { toast } from "sonner"
import { cn } from "@/lib/utils"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Textarea } from "@/components/ui/textarea"
import {
  Form,
  FormControl,
  FormDescription,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"
import { Card, CardContent } from "@/components/ui/card"
import { marketplaceService, type MarketplaceCategory } from "@/services"

/**
 * Listing type options (matches database enum)
 */
const listingTypes = [
  { value: "sell", label: "Sell Item", icon: Package, description: "Books, electronics, supplies" },
  { value: "housing", label: "Housing", icon: Home, description: "Rooms, flatmates, PG" },
  { value: "opportunity", label: "Opportunity", icon: Briefcase, description: "Jobs, internships, gigs" },
  { value: "community_post", label: "Community Post", icon: MessageSquare, description: "Questions, discussions" },
] as const

/**
 * Form validation schema
 */
const formSchema = z.object({
  listing_type: z.enum(["sell", "rent", "free", "opportunity", "housing", "community_post", "poll", "event"]),
  title: z.string().min(5, "Title must be at least 5 characters").max(100),
  description: z.string().min(20, "Description must be at least 20 characters").max(2000),
  price: z.string().optional(),
  category_id: z.string().optional(),
  city: z.string().min(2, "City is required"),
  contact_info: z.string().optional(),
})

type FormValues = z.infer<typeof formSchema>

/**
 * Props for CreateListingForm component
 */
interface CreateListingFormProps {
  categories: MarketplaceCategory[]
  userId: string
  universityId?: string
  className?: string
}

/**
 * CreateListingForm component
 * Multi-step form for creating marketplace listings
 */
export function CreateListingForm({
  categories,
  userId,
  universityId,
  className,
}: CreateListingFormProps) {
  const router = useRouter()
  const [step, setStep] = useState(1)
  const [images, setImages] = useState<File[]>([])
  const [imagePreview, setImagePreview] = useState<string[]>([])
  const [isSubmitting, setIsSubmitting] = useState(false)

  const form = useForm<FormValues>({
    resolver: zodResolver(formSchema),
    defaultValues: {
      listing_type: undefined,
      title: "",
      description: "",
      price: "",
      category_id: undefined,
      city: "",
      contact_info: "",
    },
  })

  const selectedType = form.watch("listing_type")

  /**
   * Handle image selection
   */
  const handleImageChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const files = Array.from(e.target.files || [])
    if (files.length + images.length > 5) {
      toast.error("Maximum 5 images allowed")
      return
    }

    const newImages = [...images, ...files]
    setImages(newImages)

    // Create previews
    const newPreviews = files.map((file) => URL.createObjectURL(file))
    setImagePreview([...imagePreview, ...newPreviews])
  }

  /**
   * Remove an image
   */
  const removeImage = (index: number) => {
    const newImages = images.filter((_, i) => i !== index)
    const newPreviews = imagePreview.filter((_, i) => i !== index)
    setImages(newImages)
    setImagePreview(newPreviews)
  }

  /**
   * Handle form submission
   */
  const onSubmit = async (values: FormValues) => {
    setIsSubmitting(true)

    // Convert price string to number
    const price = values.price ? parseFloat(values.price) : undefined

    try {
      await marketplaceService.createListing(
        {
          listing_type: values.listing_type,
          title: values.title,
          description: values.description,
          price: price && !isNaN(price) ? price : undefined,
          category_id: values.category_id,
          city: values.city,
          seller_id: userId,
          university_id: universityId,
        },
        images
      )

      toast.success("Listing created successfully!")
      router.push("/marketplace")
    } catch (error) {
      console.error("Failed to create listing:", error)
      toast.error("Failed to create listing. Please try again.")
    } finally {
      setIsSubmitting(false)
    }
  }

  return (
    <div className={cn("space-y-6", className)}>
      <Form {...form}>
        <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-6">
          {/* Step 1: Select Type */}
          {step === 1 && (
            <div className="space-y-4">
              <h2 className="text-lg font-semibold">What do you want to post?</h2>
              <div className="grid gap-4 sm:grid-cols-2">
                {listingTypes.map((type) => {
                  const Icon = type.icon
                  return (
                    <Card
                      key={type.value}
                      className={cn(
                        "cursor-pointer transition-all hover:border-primary",
                        selectedType === type.value && "border-primary bg-primary/5"
                      )}
                      onClick={() => {
                        form.setValue("listing_type", type.value as any)
                        setStep(2)
                      }}
                    >
                      <CardContent className="flex items-start gap-4 p-4">
                        <div className="rounded-lg bg-primary/10 p-2">
                          <Icon className="h-6 w-6 text-primary" />
                        </div>
                        <div>
                          <p className="font-medium">{type.label}</p>
                          <p className="text-sm text-muted-foreground">
                            {type.description}
                          </p>
                        </div>
                      </CardContent>
                    </Card>
                  )
                })}
              </div>
            </div>
          )}

          {/* Step 2: Details */}
          {step === 2 && (
            <div className="space-y-6">
              <div className="flex items-center gap-2">
                <Button
                  type="button"
                  variant="ghost"
                  size="sm"
                  onClick={() => setStep(1)}
                >
                  ← Back
                </Button>
                <h2 className="text-lg font-semibold">Listing Details</h2>
              </div>

              {/* Images */}
              <div className="space-y-2">
                <label className="text-sm font-medium">Images (up to 5)</label>
                <div className="flex flex-wrap gap-3">
                  {imagePreview.map((preview, index) => (
                    <div key={index} className="relative">
                      <img
                        src={preview}
                        alt={`Preview ${index + 1}`}
                        className="h-24 w-24 rounded-lg object-cover"
                      />
                      <Button
                        type="button"
                        variant="destructive"
                        size="icon"
                        className="absolute -right-2 -top-2 h-6 w-6"
                        onClick={() => removeImage(index)}
                      >
                        <X className="h-3 w-3" />
                      </Button>
                    </div>
                  ))}
                  {images.length < 5 && (
                    <label className="flex h-24 w-24 cursor-pointer items-center justify-center rounded-lg border-2 border-dashed border-muted-foreground/25 hover:border-primary">
                      <ImagePlus className="h-6 w-6 text-muted-foreground" />
                      <input
                        type="file"
                        accept="image/*"
                        multiple
                        className="hidden"
                        onChange={handleImageChange}
                      />
                    </label>
                  )}
                </div>
              </div>

              {/* Title */}
              <FormField
                control={form.control}
                name="title"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Title</FormLabel>
                    <FormControl>
                      <Input placeholder="What are you listing?" {...field} />
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )}
              />

              {/* Description */}
              <FormField
                control={form.control}
                name="description"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Description</FormLabel>
                    <FormControl>
                      <Textarea
                        placeholder="Describe your listing in detail..."
                        className="min-h-[120px]"
                        {...field}
                      />
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )}
              />

              {/* Price (for sell items and housing) */}
              {(selectedType === "sell" || selectedType === "housing") && (
                <FormField
                  control={form.control}
                  name="price"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Price (₹)</FormLabel>
                      <FormControl>
                        <Input
                          type="number"
                          placeholder="0 for free"
                          {...field}
                        />
                      </FormControl>
                      <FormDescription>
                        Enter 0 if you're giving it away for free
                      </FormDescription>
                      <FormMessage />
                    </FormItem>
                  )}
                />
              )}

              {/* Category */}
              <FormField
                control={form.control}
                name="category_id"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Category</FormLabel>
                    <Select onValueChange={field.onChange} value={field.value}>
                      <FormControl>
                        <SelectTrigger>
                          <SelectValue placeholder="Select a category" />
                        </SelectTrigger>
                      </FormControl>
                      <SelectContent>
                        {categories.map((cat) => (
                          <SelectItem key={cat.id} value={cat.id}>
                            {cat.name}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                    <FormMessage />
                  </FormItem>
                )}
              />

              {/* City */}
              <FormField
                control={form.control}
                name="city"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>City</FormLabel>
                    <FormControl>
                      <Input placeholder="Your city" {...field} />
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )}
              />

              {/* Contact Info */}
              <FormField
                control={form.control}
                name="contact_info"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Contact Info (Optional)</FormLabel>
                    <FormControl>
                      <Input
                        placeholder="Phone or email for interested buyers"
                        {...field}
                      />
                    </FormControl>
                    <FormDescription>
                      This will be shown to interested users
                    </FormDescription>
                    <FormMessage />
                  </FormItem>
                )}
              />

              {/* Submit Button */}
              <Button type="submit" className="w-full" disabled={isSubmitting}>
                {isSubmitting ? (
                  <>
                    <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                    Creating...
                  </>
                ) : (
                  "Create Listing"
                )}
              </Button>
            </div>
          )}
        </form>
      </Form>
    </div>
  )
}

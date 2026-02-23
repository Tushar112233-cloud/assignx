"use client";

import { useState } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
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
import { Separator } from "@/components/ui/separator";
import { createBanner, updateBanner } from "@/lib/admin/actions/banners";
import { BannerPreview } from "@/components/admin/banners/banner-preview";
import { toast } from "sonner";
import type { AdminBanner } from "@/lib/admin/types";

const ROLE_OPTIONS = ["admin", "user", "supervisor", "doer"];
const USER_TYPE_OPTIONS = ["student", "professional", "business"];
const LOCATION_OPTIONS = ["home", "dashboard", "projects", "global"];

export function BannerForm({ banner }: { banner?: AdminBanner }) {
  const router = useRouter();
  const searchParams = useSearchParams();
  const editId = banner?.id || searchParams.get("edit");
  const isEdit = !!editId;

  const [loading, setLoading] = useState(false);
  const [title, setTitle] = useState(banner?.title || "");
  const [subtitle, setSubtitle] = useState(banner?.subtitle || "");
  const [imageUrl, setImageUrl] = useState(banner?.image_url || "");
  const [imageUrlMobile, setImageUrlMobile] = useState(banner?.image_url_mobile || "");
  const [displayLocation, setDisplayLocation] = useState(banner?.display_location || "home");
  const [displayOrder, setDisplayOrder] = useState(banner?.display_order ?? 0);
  const [startDate, setStartDate] = useState(banner?.start_date?.split("T")[0] || "");
  const [endDate, setEndDate] = useState(banner?.end_date?.split("T")[0] || "");
  const [isActive, setIsActive] = useState(banner?.is_active ?? true);
  const [targetRoles, setTargetRoles] = useState<string[]>(banner?.target_roles || []);
  const [targetUserTypes, setTargetUserTypes] = useState<string[]>(banner?.target_user_types || []);
  const [ctaText, setCtaText] = useState(banner?.cta_text || "");
  const [ctaUrl, setCtaUrl] = useState(banner?.cta_url || "");
  const [ctaAction, setCtaAction] = useState(banner?.cta_action || "");

  const toggleRole = (role: string) => {
    setTargetRoles((prev) =>
      prev.includes(role) ? prev.filter((r) => r !== role) : [...prev, role]
    );
  };

  const toggleUserType = (type: string) => {
    setTargetUserTypes((prev) =>
      prev.includes(type) ? prev.filter((t) => t !== type) : [...prev, type]
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
      const formData = {
        title: title.trim(),
        subtitle: subtitle.trim() || undefined,
        image_url: imageUrl.trim() || undefined,
        image_url_mobile: imageUrlMobile.trim() || undefined,
        display_location: displayLocation,
        display_order: displayOrder,
        start_date: startDate || undefined,
        end_date: endDate || undefined,
        is_active: isActive,
        target_roles: targetRoles,
        target_user_types: targetUserTypes,
        cta_text: ctaText.trim() || undefined,
        cta_url: ctaUrl.trim() || undefined,
        cta_action: ctaAction.trim() || undefined,
      };

      if (isEdit && editId) {
        await updateBanner(editId, formData);
        toast.success("Banner updated successfully");
      } else {
        await createBanner(formData);
        toast.success("Banner created successfully");
      }
      router.push("/admin/banners");
      router.refresh();
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Failed to save");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="grid gap-6 lg:grid-cols-[1fr_400px]">
      <Card>
        <CardHeader>
          <CardTitle>{isEdit ? "Edit Banner" : "New Banner"}</CardTitle>
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
                  placeholder="Banner title"
                  required
                />
              </div>
              <div className="flex flex-col gap-2">
                <Label htmlFor="subtitle">Subtitle</Label>
                <Input
                  id="subtitle"
                  value={subtitle}
                  onChange={(e) => setSubtitle(e.target.value)}
                  placeholder="Optional subtitle"
                />
              </div>
            </div>

            <div className="grid gap-4 sm:grid-cols-2">
              <div className="flex flex-col gap-2">
                <Label htmlFor="image_url">Image URL (Desktop)</Label>
                <Input
                  id="image_url"
                  value={imageUrl}
                  onChange={(e) => setImageUrl(e.target.value)}
                  placeholder="https://..."
                />
              </div>
              <div className="flex flex-col gap-2">
                <Label htmlFor="image_url_mobile">Image URL (Mobile)</Label>
                <Input
                  id="image_url_mobile"
                  value={imageUrlMobile}
                  onChange={(e) => setImageUrlMobile(e.target.value)}
                  placeholder="https://..."
                />
              </div>
            </div>

            <div className="grid gap-4 sm:grid-cols-3">
              <div className="flex flex-col gap-2">
                <Label htmlFor="display_location">Display Location</Label>
                <Select value={displayLocation} onValueChange={setDisplayLocation}>
                  <SelectTrigger>
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    {LOCATION_OPTIONS.map((loc) => (
                      <SelectItem key={loc} value={loc}>
                        {loc.charAt(0).toUpperCase() + loc.slice(1)}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
              <div className="flex flex-col gap-2">
                <Label htmlFor="display_order">Display Order</Label>
                <Input
                  id="display_order"
                  type="number"
                  value={displayOrder}
                  onChange={(e) => setDisplayOrder(parseInt(e.target.value) || 0)}
                  min={0}
                />
              </div>
              <div className="flex flex-col gap-2">
                <Label>Status</Label>
                <label className="flex items-center gap-2 pt-2 text-sm">
                  <Checkbox
                    checked={isActive}
                    onCheckedChange={(checked) => setIsActive(!!checked)}
                  />
                  Active
                </label>
              </div>
            </div>

            <div className="grid gap-4 sm:grid-cols-2">
              <div className="flex flex-col gap-2">
                <Label htmlFor="start_date">Start Date</Label>
                <Input
                  id="start_date"
                  type="date"
                  value={startDate}
                  onChange={(e) => setStartDate(e.target.value)}
                />
              </div>
              <div className="flex flex-col gap-2">
                <Label htmlFor="end_date">End Date</Label>
                <Input
                  id="end_date"
                  type="date"
                  value={endDate}
                  onChange={(e) => setEndDate(e.target.value)}
                />
              </div>
            </div>

            <Separator />

            <div className="flex flex-col gap-2">
              <Label>Target Roles</Label>
              <div className="flex flex-wrap gap-4">
                {ROLE_OPTIONS.map((role) => (
                  <label key={role} className="flex items-center gap-2 text-sm">
                    <Checkbox
                      checked={targetRoles.includes(role)}
                      onCheckedChange={() => toggleRole(role)}
                    />
                    <span className="capitalize">{role}</span>
                  </label>
                ))}
              </div>
            </div>

            <div className="flex flex-col gap-2">
              <Label>Target User Types</Label>
              <div className="flex flex-wrap gap-4">
                {USER_TYPE_OPTIONS.map((type) => (
                  <label key={type} className="flex items-center gap-2 text-sm">
                    <Checkbox
                      checked={targetUserTypes.includes(type)}
                      onCheckedChange={() => toggleUserType(type)}
                    />
                    <span className="capitalize">{type}</span>
                  </label>
                ))}
              </div>
            </div>

            <Separator />

            <div className="grid gap-4 sm:grid-cols-3">
              <div className="flex flex-col gap-2">
                <Label htmlFor="cta_text">CTA Text</Label>
                <Input
                  id="cta_text"
                  value={ctaText}
                  onChange={(e) => setCtaText(e.target.value)}
                  placeholder="Learn More"
                />
              </div>
              <div className="flex flex-col gap-2">
                <Label htmlFor="cta_url">CTA URL</Label>
                <Input
                  id="cta_url"
                  value={ctaUrl}
                  onChange={(e) => setCtaUrl(e.target.value)}
                  placeholder="https://..."
                />
              </div>
              <div className="flex flex-col gap-2">
                <Label htmlFor="cta_action">CTA Action</Label>
                <Input
                  id="cta_action"
                  value={ctaAction}
                  onChange={(e) => setCtaAction(e.target.value)}
                  placeholder="navigate, open_modal"
                />
              </div>
            </div>

            <div className="flex gap-3">
              <Button type="submit" disabled={loading}>
                {loading
                  ? "Saving..."
                  : isEdit
                    ? "Update Banner"
                    : "Create Banner"}
              </Button>
              <Button
                type="button"
                variant="outline"
                onClick={() => router.push("/admin/banners")}
              >
                Cancel
              </Button>
            </div>
          </form>
        </CardContent>
      </Card>

      <div className="lg:sticky lg:top-4">
        <BannerPreview
          title={title}
          subtitle={subtitle}
          imageUrl={imageUrl}
          ctaText={ctaText}
        />
      </div>
    </div>
  );
}

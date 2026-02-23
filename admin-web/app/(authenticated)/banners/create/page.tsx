import { BannerForm } from "@/components/admin/banners/banner-form";

export const metadata = { title: "Create Banner - AssignX Admin" };

export default function CreateBannerPage() {
  return (
    <div className="flex flex-col gap-4 py-4">
      <div className="px-4 lg:px-6">
        <h1 className="text-2xl font-bold tracking-tight">Create Banner</h1>
        <p className="text-muted-foreground">
          Add a new promotional banner
        </p>
      </div>
      <div className="px-4 lg:px-6">
        <BannerForm />
      </div>
    </div>
  );
}

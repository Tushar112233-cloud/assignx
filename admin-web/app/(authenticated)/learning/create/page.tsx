import { LearningForm } from "@/components/admin/learning/learning-form";

export const metadata = { title: "Create Learning Resource - AssignX Admin" };

export default function CreateLearningResourcePage() {
  return (
    <div className="flex flex-col gap-4 py-4">
      <div className="px-4 lg:px-6">
        <h1 className="text-2xl font-bold tracking-tight">
          Create Learning Resource
        </h1>
        <p className="text-muted-foreground">
          Add a new educational resource
        </p>
      </div>
      <div className="px-4 lg:px-6">
        <LearningForm />
      </div>
    </div>
  );
}

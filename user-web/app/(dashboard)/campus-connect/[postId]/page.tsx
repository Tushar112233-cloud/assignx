"use client";

import { use } from "react";
import { PostDetailView } from "@/components/campus-connect";

interface PostDetailPageProps {
  params: Promise<{
    postId: string;
  }>;
}

/**
 * Post Detail Page
 * Full view of a campus connect post with comments
 */
export default function PostDetailPage({ params }: PostDetailPageProps) {
  const { postId } = use(params);
  return <PostDetailView postId={postId} />;
}
